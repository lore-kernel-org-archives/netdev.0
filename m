From: Koichiro Den <den@klaipeden.com>
Subject: Re: [net-next 1/3] tcp: avoid useless copying and collapsing of
 just one skb
Date: Sun, 15 Oct 2017 11:32:48 +0900
Message-ID: <1508034768.29679.1.camel@klaipeden.com>
References: <20171014072745.23462-1-den@klaipeden.com>
         <20171014072745.23462-2-den@klaipeden.com>
         <1507995761.31614.56.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sender-of-o52.zoho.com ([135.84.80.217]:21362 "EHLO
        sender-of-o52.zoho.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751303AbdJOCcz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 22:32:55 -0400
In-Reply-To: <1507995761.31614.56.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-10-14 at 08:42 -0700, Eric Dumazet wrote:
> On Sat, 2017-10-14 at 16:27 +0900, Koichiro Den wrote:
> > On the starting point chosen, it could be possible that just one skb
> > remains in between the range provided, leading to copying and re-insertion
> > of rb node, which is useless with respect to the rcv buf measurement.
> > This is rather probable in ooo queue case, in which non-contiguous bloated
> > packets have been queued up.
> > 
> > Signed-off-by: Koichiro Den <den@klaipeden.com>
> > ---
> >  net/ipv4/tcp_input.c | 3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> > index d0682ce2a5d6..1d785b5bf62d 100644
> > --- a/net/ipv4/tcp_input.c
> > +++ b/net/ipv4/tcp_input.c
> > @@ -4807,7 +4807,8 @@ tcp_collapse(struct sock *sk, struct sk_buff_head
> > *list, struct rb_root *root,
> >  		start = TCP_SKB_CB(skb)->end_seq;
> >  	}
> >  	if (end_of_skbs ||
> > -	    (TCP_SKB_CB(skb)->tcp_flags & (TCPHDR_SYN | TCPHDR_FIN)))
> > +	    (TCP_SKB_CB(skb)->tcp_flags & (TCPHDR_SYN | TCPHDR_FIN)) ||
> > +	    (TCP_SKB_CB(skb)->seq == start && TCP_SKB_CB(skb)->end_seq ==
> > end))
> >  		return;
> >  
> >  	__skb_queue_head_init(&tmp);
> 
> 
> What do you mean by useless ?
> 
> Surely if this skb contains 17 segments (some USB drivers allocate 8KB
> per frame), we want to collapse them to save memory.
> 
> So I do not agree with this patch.
> 
> 
I missed that, and sorry about bothering with all, I totally misunderstood it.
Thank you for all of them.
