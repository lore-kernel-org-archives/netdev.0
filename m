From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: IPv6 :  ICMPV6_DEST_UNREACH type with ICMPV6_NOROUTE code
Date: Fri, 9 May 2003 13:34:58 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16059.37474.453731.39031@robur.slu.se>
References: <003e01c313b8$e55db620$28acfe81@seong>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Seong Moon" <seong@etri.re.kr>
In-Reply-To: <003e01c313b8$e55db620$28acfe81@seong>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Seong Moon writes:

 > I found that when the kernel has no forwarding entry of a packet,
 > the kernel sends an ICMPV6_DEST_UNREACH icmp message with
 > ICMPV6_ADDR_UNREACH code  to the source of the packet.
 > 
 > But According to RFC 2463, If the kerenl has no forwarding entry of a
 > packet,
 > the kernel must send an ICMPV6_DEST_UNREACH icmp message with ICMPV6_NOROUTE
 > code.
 > How about you ? Am I right ?

 I think you are...

--- linux/net/ipv6/route.c.030508       2003-03-24 23:01:14.000000000 +0100
+++ linux/net/ipv6/route.c      2003-05-09 13:29:31.000000000 +0200
@@ -1166,7 +1166,7 @@
 int ip6_pkt_discard(struct sk_buff *skb)
 {
        IP6_INC_STATS(Ip6OutNoRoutes);
-       icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_ADDR_UNREACH, 0, skb->dev);
+       icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_NOROUTE, 0, skb->dev);
        kfree_skb(skb);
        return 0;
 }


 Cheers.
						--ro
