From: Lance Richardson <lrichard@redhat.com>
Subject: Re: [PATCH net] ipv4: allow local fragmentation in
 ip_finish_output_gso()
Date: Wed, 2 Nov 2016 16:10:16 -0400 (EDT)
Message-ID: <1893627626.93159878.1478117416635.JavaMail.zimbra@redhat.com>
References: <1478104158-9504-1-git-send-email-lrichard@redhat.com> <20161102172036.GD17689@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jtluka@redhat.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4-phx2.redhat.com ([209.132.183.25]:60268 "EHLO
        mx4-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756389AbcKBUK0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 16:10:26 -0400
In-Reply-To: <20161102172036.GD17689@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- Original Message -----
> From: "Florian Westphal" <fw@strlen.de>
> To: "Lance Richardson" <lrichard@redhat.com>
> Cc: netdev@vger.kernel.org, fw@strlen.de, jtluka@redhat.com
> Sent: Wednesday, November 2, 2016 1:20:36 PM
> Subject: Re: [PATCH net] ipv4: allow local fragmentation in ip_finish_output_gso()
> 
> Lance Richardson <lrichard@redhat.com> wrote:
> > Some configurations (e.g. geneve interface with default
> > MTU of 1500 over an ethernet interface with 1500 MTU) result
> > in the transmission of packets that exceed the configured MTU.
> > While this should be considered to be a "bad" configuration,
> > it is still allowed and should not result in the sending
> > of packets that exceed the configured MTU.
> > 
> > Fix by dropping the assumption in ip_finish_output_gso() that
> > locally originated gso packets will never need fragmentation.
> > Basic testing using iperf (observing CPU usage and bandwidth)
> > have shown no measurable performance impact for traffic not
> > requiring fragmentation.
> > 
> > Fixes: c7ba65d7b649 ("net: ip: push gso skb forwarding handling down the
> > stack")
> > Reported-by: Jan Tluka <jtluka@redhat.com>
> > Signed-off-by: Lance Richardson <lrichard@redhat.com>
> > ---
> >  net/ipv4/ip_output.c | 6 ++----
> >  1 file changed, 2 insertions(+), 4 deletions(-)
> > 
> > diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> > index 03e7f73..4971401 100644
> > --- a/net/ipv4/ip_output.c
> > +++ b/net/ipv4/ip_output.c
> > @@ -239,11 +239,9 @@ static int ip_finish_output_gso(struct net *net,
> > struct sock *sk,
> >  	struct sk_buff *segs;
> >  	int ret = 0;
> >  
> > -	/* common case: fragmentation of segments is not allowed,
> > -	 * or seglen is <= mtu
> > +	/* common case: seglen is <= mtu
> >  	 */
> > -	if (((IPCB(skb)->flags & IPSKB_FRAG_SEGS) == 0) ||
> > -	      skb_gso_validate_mtu(skb, mtu))
> > +	if (skb_gso_validate_mtu(skb, mtu))
> 
> IPSKB_FRAG_SEGS is now useless and should be removed.
> 

Thanks, Florian, I've removed IPSKB_FRAG_SEGS in v2.

   Lance
