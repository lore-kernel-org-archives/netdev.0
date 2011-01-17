From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [PATCH] net_sched: factorize qdisc stats handling
Date: Mon, 17 Jan 2011 22:55:23 +0100 (CET)
Message-ID: <Pine.LNX.4.64.1101172243470.15896@ask.diku.dk>
References: <20110106195614.20dbc402@nehalam>
 <AANLkTi=pqZ3CwLTAZnhd-cyQNj8OSeBHsP_bFiH3hJ-_@mail.gmail.com>
 <20110107200234.3f5e7ff8@nehalam> <1294478789.2709.79.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>,
	Fabio Checconi <fabio@gandalf.sssup.it>,
	netdev <netdev@vger.kernel.org>,
	Luigi Rizzo <rizzo@iet.unipi.it>, hawk@comx.dk
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:55309 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752750Ab1AQVza (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Jan 2011 16:55:30 -0500
In-Reply-To: <1294478789.2709.79.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sat, 8 Jan 2011, Eric Dumazet wrote:
>> Changli Gao <xiaosuo@gmail.com> wrote:
>>
>>>> +       cl->bstats.packets += skb_is_gso(skb)?skb_shinfo(skb)->gso_segs:1;

What about the qlen when we enqueue a GSO packet? Should we account for 
the number of internal GSO packets, or just account a GSO packet as a 
single packet?

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 0918834..1a8c0a3 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -453,7 +453,8 @@ static int pfifo_fast_enqueue(struct sk_buff *skb, 
struct Qdisc* qdisc)
                 struct sk_buff_head *list = band2list(priv, band);

                 priv->bitmap |= (1 << band);
-               qdisc->q.qlen++;
+               /* Should the number of GSO packets be taken into account?*/
+               qdisc->q.qlen += skb_is_gso(skb)?skb_shinfo(skb)->gso_segs:1;
                 return __qdisc_enqueue_tail(skb, qdisc, list);
         }

Is is at all legal to modify the q.qlen this way?

Cheers
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
