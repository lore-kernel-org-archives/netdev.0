From: Asim Shankar <asimshankar@gmail.com>
Subject: [PATCH 2.6.11.7] sch_htb: Drop packet when direct queue is full
Date: Mon, 25 Apr 2005 14:15:05 -0500 (CDT)
Message-ID: <Pine.LNX.4.61.0504251409560.24260@limnos.csrd.uiuc.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

htb_enqueue(): Free skb and return NET_XMIT_DROP if a packet is destined 
for the direct_queue but the direct_queue is full. (Before patch: 
Erroneously returned NET_XMIT_SUCCESS even though packet was not enqueued)

Signed-off-by: Asim Shankar <asimshankar@gmail.com>

--- linux-2.6.11.7/net/sched/sch_htb.c.orig	2005-04-21 17:40:05.305709014 -0500
+++ linux-2.6.11.7/net/sched/sch_htb.c	2005-04-21 17:35:27.872624173 -0500
@@ -717,6 +717,10 @@ static int htb_enqueue(struct sk_buff *s
  	if (q->direct_queue.qlen < q->direct_qlen) {
  	    __skb_queue_tail(&q->direct_queue, skb);
  	    q->direct_pkts++;
+	} else {
+	    kfree_skb(skb);
+	    sch->qstats.drops++;
+	    return NET_XMIT_DROP;
  	}
  #ifdef CONFIG_NET_CLS_ACT
      } else if (!cl) {
