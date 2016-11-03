From: Lance Richardson <lrichard@redhat.com>
Subject: Re: [PATCH net v3] ipv4: allow local fragmentation in
 ip_finish_output_gso()
Date: Thu, 3 Nov 2016 09:06:27 -0400 (EDT)
Message-ID: <274982955.93728733.1478178387534.JavaMail.zimbra@redhat.com>
References: <1478118977-19608-1-git-send-email-lrichard@redhat.com> <20161103094239.13ac8ac2@pixies>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, jtluka@redhat.com,
        hannes@stressinduktion.org
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4-phx2.redhat.com ([209.132.183.25]:59083 "EHLO
        mx4-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756642AbcKCNGl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 09:06:41 -0400
In-Reply-To: <20161103094239.13ac8ac2@pixies>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: "Shmulik Ladkani" <shmulik.ladkani@gmail.com>
> To: "Lance Richardson" <lrichard@redhat.com>
> Cc: netdev@vger.kernel.org, fw@strlen.de, jtluka@redhat.com, hannes@stressinduktion.org
> Sent: Thursday, November 3, 2016 3:42:39 AM
> Subject: Re: [PATCH net v3] ipv4: allow local fragmentation in ip_finish_output_gso()
> 
> On Wed,  2 Nov 2016 16:36:17 -0400
> Lance Richardson <lrichard@redhat.com> wrote:
> 
> > -	/* common case: fragmentation of segments is not allowed,
> > -	 * or seglen is <= mtu
> > +	/* common case: seglen is <= mtu
> >  	 */
> > -	if (((IPCB(skb)->flags & IPSKB_FRAG_SEGS) == 0) ||
> > -	      skb_gso_validate_mtu(skb, mtu))
> > +	if (skb_gso_validate_mtu(skb, mtu))
> >  		return ip_finish_output2(net, sk, skb);
> 
> OK.
> Resembles https://patchwork.ozlabs.org/patch/644724/ ;)
> 
> > -	if (skb_iif && !(df & htons(IP_DF))) {
> > -		/* Arrived from an ingress interface, got encapsulated, with
> > -		 * fragmentation of encapulating frames allowed.
> > -		 * If skb is gso, the resulting encapsulated network segments
> > -		 * may exceed dst mtu.
> > -		 * Allow IP Fragmentation of segments.
> > -		 */
> > -		IPCB(skb)->flags |= IPSKB_FRAG_SEGS;
> > -	}
> 
> The only potential issue I see removing this, is that the KNOWLEDGE of
> the forwarding/tunnel-bridging usecases (that require a
> skb_gso_validate_mtu check) is lost.
> 
> Meaning, if one decides (as claimed in the past) that locally generated
> traffic must NOT go through fragmentation validation, then no one
> remembers those other valid usecases (which are very specific and not
> trivial to imagine) that MUST go through it; Therefore it can easily get
> broken.
> 

Hi Shmulik,

It is my understanding that the test to avoid fragmentation validation
for locally originated packets was a performance optimization which was
based on the premise that the IP stack will never produce locally originated
packets with an MTU mismatch. Tunneling encapsulation breaks this premise.
For correctness (honoring configured MTU), it seems we cannot avoid calling
skb_gso_validate_mtu().

> Maybe we can elaborate in the comment above the call to
> skb_gso_validate_mtu in ip_finish_output_gso?

I'm not sure what could be added that would help, was there something
specific you had in mind?

Thanks for reviewing this.

Regards,

   Lance
> 
> Best,
> Shmulik
> 
