From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] [NETFILTER] ip_queue: Fix wrong skb->len == nlmsg_len
	assumption
Date: Tue, 7 Mar 2006 13:31:43 +0100
Message-ID: <20060307123143.GO9559@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

The size of the skb carrying the netlink message is not
equivalent to the length of the actual netlink message
due to padding. ip_queue matches the length of the payload
against the original packet size to determine if packet
mangling is desired, due to the above wrong assumption
arbitary packets may not be mangled depening on their
original size.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6/net/ipv4/netfilter/ip_queue.c
===================================================================
--- net-2.6.orig/net/ipv4/netfilter/ip_queue.c
+++ net-2.6/net/ipv4/netfilter/ip_queue.c
@@ -524,7 +524,7 @@ ipq_rcv_skb(struct sk_buff *skb)
 	write_unlock_bh(&queue_lock);
 	
 	status = ipq_receive_peer(NLMSG_DATA(nlh), type,
-	                          skblen - NLMSG_LENGTH(0));
+	                          nlmsglen - NLMSG_LENGTH(0));
 	if (status < 0)
 		RCV_SKB_FAIL(status);
 		
Index: net-2.6/net/ipv6/netfilter/ip6_queue.c
===================================================================
--- net-2.6.orig/net/ipv6/netfilter/ip6_queue.c
+++ net-2.6/net/ipv6/netfilter/ip6_queue.c
@@ -522,7 +522,7 @@ ipq_rcv_skb(struct sk_buff *skb)
 	write_unlock_bh(&queue_lock);
 	
 	status = ipq_receive_peer(NLMSG_DATA(nlh), type,
-	                          skblen - NLMSG_LENGTH(0));
+	                          nlmsglen - NLMSG_LENGTH(0));
 	if (status < 0)
 		RCV_SKB_FAIL(status);
 		
