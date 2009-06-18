From: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
Subject: [PATCH v2] ftrace: change the export format of trace_kfree_skb()
Date: Thu, 18 Jun 2009 11:26:28 +0800
Message-ID: <4A39B3E4.6060004@cn.fujitsu.com>
References: <4A2DF91F.7030906@cn.fujitsu.com> <20090609182730.GA6057@nowhere> <4A2F0F1D.7010101@cn.fujitsu.com> <20090610072618.GA6016@nowhere>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Frederic Weisbecker <fweisbec@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Steven Rostedt <rostedt@goodmis.org>,
	David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51711 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752144AbZFRD0E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2009 23:26:04 -0400
In-Reply-To: <20090610072618.GA6016@nowhere>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use %pf instead of %p to output the function's address and print the
protocol's name.

Before patch:

  <idle>-0     [000] 60144.542521: kfree_skb: skbaddr=de7b8240 protocol=2048 location=c1365429
  <idle>-0     [000] 60164.488153: kfree_skb: skbaddr=da66f900 protocol=2048 location=c1365429
  <idle>-0     [000] 60193.493933: kfree_skb: skbaddr=deaeb480 protocol=4 location=c134ec25
  <idle>-0     [000] 60253.118421: kfree_skb: skbaddr=de7c4900 protocol=4 location=c134ec25
          
After patch:

  <idle>-0     [000]   169.979205: kfree_skb: skbaddr=ceddc240 protocol=ETH_P_802_2 location=netif_receive_skb
  <idle>-0     [000]   172.587000: kfree_skb: skbaddr=ceddc300 protocol=ETH_P_802_2 location=netif_receive_skb
    ping-3391  [000]   192.109803: kfree_skb: skbaddr=ceddc900 protocol=ETH_P_IP location=icmp_rcv
    ping-3391  [000]   192.109902: kfree_skb: skbaddr=ceddc780 protocol=ETH_P_IP location=icmp_rcv

Changelog v1->v2:
Convert protocol from raw numeric to its name as Frederic's suggestion

Signed-off-by: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
Acked-by: Frederic Weisbecker <fweisbec@gmail.com>
---
 include/trace/events/skb.h |   70 ++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 68 insertions(+), 2 deletions(-)

diff --git a/include/trace/events/skb.h b/include/trace/events/skb.h
index 1e8fabb..2496060 100644
--- a/include/trace/events/skb.h
+++ b/include/trace/events/skb.h
@@ -7,6 +7,71 @@
 #undef TRACE_SYSTEM
 #define TRACE_SYSTEM skb
 
+#define protocol_name(protocol) { protocol, #protocol }
+#define show_protocol_name(val)					\
+	__print_symbolic(val,					\
+			 protocol_name(ETH_P_LOOP),		\
+			 protocol_name(ETH_P_PUP),		\
+			 protocol_name(ETH_P_PUPAT),		\
+			 protocol_name(ETH_P_IP),		\
+			 protocol_name(ETH_P_X25),		\
+			 protocol_name(ETH_P_ARP),		\
+			 protocol_name(ETH_P_BPQ),		\
+			 protocol_name(ETH_P_IEEEPUP),		\
+			 protocol_name(ETH_P_IEEEPUPAT),	\
+			 protocol_name(ETH_P_DEC),		\
+			 protocol_name(ETH_P_DNA_DL),		\
+			 protocol_name(ETH_P_DNA_RC),		\
+			 protocol_name(ETH_P_DNA_RT),		\
+			 protocol_name(ETH_P_LAT),		\
+			 protocol_name(ETH_P_DIAG),		\
+			 protocol_name(ETH_P_CUST),		\
+			 protocol_name(ETH_P_SCA),		\
+			 protocol_name(ETH_P_TEB),		\
+			 protocol_name(ETH_P_RARP),		\
+			 protocol_name(ETH_P_ATALK),		\
+			 protocol_name(ETH_P_AARP),		\
+			 protocol_name(ETH_P_8021Q),		\
+			 protocol_name(ETH_P_IPX),		\
+			 protocol_name(ETH_P_IPV6),		\
+			 protocol_name(ETH_P_PAUSE),		\
+			 protocol_name(ETH_P_SLOW),		\
+			 protocol_name(ETH_P_WCCP),		\
+			 protocol_name(ETH_P_PPP_DISC),		\
+			 protocol_name(ETH_P_PPP_SES),		\
+			 protocol_name(ETH_P_MPLS_UC),		\
+			 protocol_name(ETH_P_MPLS_MC),		\
+			 protocol_name(ETH_P_ATMMPOA),		\
+			 protocol_name(ETH_P_ATMFATE),		\
+			 protocol_name(ETH_P_PAE),		\
+			 protocol_name(ETH_P_AOE),		\
+			 protocol_name(ETH_P_TIPC),		\
+			 protocol_name(ETH_P_FCOE),		\
+			 protocol_name(ETH_P_FIP),		\
+			 protocol_name(ETH_P_EDSA),		\
+			 protocol_name(ETH_P_802_3),		\
+			 protocol_name(ETH_P_AX25),		\
+			 protocol_name(ETH_P_ALL),		\
+			 protocol_name(ETH_P_802_2),		\
+			 protocol_name(ETH_P_SNAP),		\
+			 protocol_name(ETH_P_DDCMP),		\
+			 protocol_name(ETH_P_WAN_PPP),		\
+			 protocol_name(ETH_P_PPP_MP),		\
+			 protocol_name(ETH_P_LOCALTALK),	\
+			 protocol_name(ETH_P_CAN),		\
+			 protocol_name(ETH_P_PPPTALK),		\
+			 protocol_name(ETH_P_TR_802_2),		\
+			 protocol_name(ETH_P_MOBITEX),		\
+			 protocol_name(ETH_P_CONTROL),		\
+			 protocol_name(ETH_P_IRDA),		\
+			 protocol_name(ETH_P_ECONET),		\
+			 protocol_name(ETH_P_HDLC),		\
+			 protocol_name(ETH_P_ARCNET),		\
+			 protocol_name(ETH_P_DSA),		\
+			 protocol_name(ETH_P_TRAILER),		\
+			 protocol_name(ETH_P_PHONET),		\
+			 protocol_name(ETH_P_IEEE802154))
+
 /*
  * Tracepoint for free an sk_buff:
  */
@@ -30,8 +95,9 @@ TRACE_EVENT(kfree_skb,
 		__entry->location = location;
 	),
 
-	TP_printk("skbaddr=%p protocol=%u location=%p",
-		__entry->skbaddr, __entry->protocol, __entry->location)
+	TP_printk("skbaddr=%p protocol=%s location=%pf",
+		  __entry->skbaddr, show_protocol_name(__entry->protocol),
+		  __entry->location)
 );
 
 #endif /* _TRACE_SKB_H */
-- 
1.6.1.2


