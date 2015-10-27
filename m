From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net v2 2/4] ipv4: add defensive check for CHECKSUM_PARTIAL
 skbs in ip_fragment
Date: Tue, 27 Oct 2015 20:15:27 +0100
Message-ID: <1445973327.507378.421829321.15264A08@webmail.messagingengine.com>
References: <1445958135-19805-1-git-send-email-hannes@stressinduktion.org>
 <1445958135-19805-3-git-send-email-hannes@stressinduktion.org>
 <562FCA18.8090008@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, vyasevich@gmail.com, bcodding@redhat.com,
	tom@herbertland.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:49142 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964927AbbJ0TP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 15:15:27 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 74A2B20A15
	for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 15:15:27 -0400 (EDT)
In-Reply-To: <562FCA18.8090008@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sergei,

On Tue, Oct 27, 2015, at 20:01, Sergei Shtylyov wrote:
> On 10/27/2015 06:02 PM, Hannes Frederic Sowa wrote:
> 
> > CHECKSUM_PARTIAL skbs should never arrive in ip_fragment. If we get one
> > of those warn about them once and handle them gracefully by recalculating
> > the checksum.
> >
> > Cc: Eric Dumazet <edumazet@google.com>
> > Cc: Vlad Yasevich <vyasevich@gmail.com>
> > Cc: Benjamin Coddington <bcodding@redhat.com>
> > Cc: Tom Herbert <tom@herbertland.com>
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > ---
> >   net/ipv4/ip_output.c | 8 +++++---
> >   1 file changed, 5 insertions(+), 3 deletions(-)
> >
> > diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> > index 0b02417..3f94a3b 100644
> > --- a/net/ipv4/ip_output.c
> > +++ b/net/ipv4/ip_output.c
> > @@ -533,6 +533,11 @@ int ip_do_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
> >
> >   	dev = rt->dst.dev;
> >
> > +	/* for offloaded checksums cleanup checksum before fragmentation */
> > +	if (WARN_ON_ONCE(skb->ip_summed == CHECKSUM_PARTIAL) &&
> > +	    (err = skb_checksum_help(skb)))
> 
>     scripts/checkpatch.pl shou;d have complained about using = in the
>     *if* 
> expression.

I know and I ignored it deliberately because I found it nicer this way.
I made sure gcc does not complain by using extra braces around the
assignment.

Bye,
Hannes
