From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: Accept ESP packets regardless of UDP
 encapsulation mode
Date: Thu, 18 Dec 2008 19:23:13 -0800 (PST)
Message-ID: <20081218.192313.250049404.davem@davemloft.net>
References: <E1LDGgX-0007JE-T9@gondolin.me.apana.org.au>
	<1229603816.10402.178.camel@martin>
	<20081218205406.GA451@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: martin@strongswan.org, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36599
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752078AbYLSDXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 22:23:11 -0500
In-Reply-To: <20081218205406.GA451@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 19 Dec 2008 07:54:06 +1100

> On Thu, Dec 18, 2008 at 01:36:56PM +0100, Martin Willi wrote:
> > 
> > >From the key manager perspective, I can enable or disable UDP
> > encapsulation, fine. I decide locally what I'll use for outgoing
> > packets. But how should I know what the peer uses? I can't, it isn't
> > negotiated. It is, by the standard, perfectly valid to send UDP
> > encapsulated packets if the peer wants to do so. And there is no need to
> > communicate this to the key manager, there is actually no such mechanism
> > in IKEv2. Therefore I need the kernel to accept packet, encapsulated or
> > not.
> 
> Even if the kernel did accept such packets, there is no guarantee
> that your return traffic will make it back to the other side because
> stateful firewalls may be present.
> 
> Responding with unencapsulated ESP traffic when the peer is sending
> you UDP-encapsulated traffic is just not going to fly.
> 
> BTW I think the IKEv2 draft has stuffed it up on this one (though
> luckily it hasn't made it to RFC yet).  I'll open a report on it.

I'm going to revert the change from net-next-2.6 from now
becasue:

1) The general scheme's validity is still suspect and under
   discussion

2) The change has a known bug (the UDP header access issue)

3) Martin can apply the change locally to do testing until we
   work this stuff out.

Thanks guys.
