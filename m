From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 1/2] ipv4: hash net ptr into fragmentation bucket
 selection
Date: Wed, 25 Mar 2015 16:16:26 +0100
Message-ID: <1427296586.2333772.245087045.6283C1D9@webmail.messagingengine.com>
References: <8d98fd0e002553538fb43e5fcafff38f3d65153f.1427291651.git.hannes@stressinduktion.org>
 <1427294700.25985.114.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Flavio Leitner <fbl@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:48044 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932137AbbCYPQ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 11:16:27 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 0EC9C2126D
	for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 11:16:24 -0400 (EDT)
In-Reply-To: <1427294700.25985.114.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, Mar 25, 2015, at 15:45, Eric Dumazet wrote:
> On Wed, 2015-03-25 at 15:00 +0100, Hannes Frederic Sowa wrote:
> > As namespaces are sometimes used with overlapping ip address ranges,
> > we should also use the namespace as input to the hash to select the ip
> > fragmentation counter bucket.
> > 
> > Cc: Eric Dumazet <edumazet@google.com>
> > Cc: Flavio Leitner <fbl@redhat.com>
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > ---
> >  drivers/net/ppp/pptp.c          | 2 +-
> >  net/netfilter/ipvs/ip_vs_xmit.c | 5 +++--
> >  2 files changed, 4 insertions(+), 3 deletions(-)
> > 
> > diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
> > index 1dc628f..e3bfbd4d 100644
> > --- a/drivers/net/ppp/pptp.c
> > +++ b/drivers/net/ppp/pptp.c
> > @@ -281,7 +281,7 @@ static int pptp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
> >  	nf_reset(skb);
> >  
> >  	skb->ip_summed = CHECKSUM_NONE;
> > -	ip_select_ident(skb, NULL);
> > +	ip_select_ident(sock_net(sk), skb, NULL);
> >  	ip_send_check(iph);
> >  
> 
> I do not see how this would compile, without corresponding change in
> ip_select_ident() ?

Cheers! ;)

We have a very slow coffee machine, so while waiting for a new one to be
produced I forgot to squash the ipv4 commits and just send them out.

> Or maybe I should drink this coffee ;)
> 
> Really, Redhat should tell truth to its customers : frags are bad

We still have to support Google's DNS servers, too. ;)

Bye,
Hannes
