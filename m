From: "Seong Moon" <seong@etri.re.kr>
Subject: IPv6 :  ICMPV6_DEST_UNREACH type with ICMPV6_NOROUTE code
Date: Tue, 6 May 2003 19:18:47 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <003e01c313b8$e55db620$28acfe81@seong>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi, there.
I'm recently analyzing the kernel source for IPv6 router.

I found that when the kernel has no forwarding entry of a packet,
the kernel sends an ICMPV6_DEST_UNREACH icmp message with
ICMPV6_ADDR_UNREACH code
to the source of the packet.

But According to RFC 2463, If the kerenl has no forwarding entry of a
packet,
the kernel must send an ICMPV6_DEST_UNREACH icmp message with ICMPV6_NOROUTE
code.

In my opinion, ip6_pkt_discard() should be modified as follows :

int ip6_pkt_discard(struct sk_buff *skb)
{
    IP6_INC_STATS(Ip6OutNoRoutes);
    /* icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_ADDR_UNREACH, 0,
skb->dev); */
    icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_NOROUTE, 0, skb->dev);
    kfree_skb(skb);
    return 0;
}

How about you ? Am I right ?

And I found another doubtable thing,
ipv6_routing_header() sends an ICMPv6 Parameter Problem message if the
extention header's length is odd value.
Then ICMPv6 Parameter Problem Message includes the pointer that indicates
the byte offset of errorneous field in a packet.
ipv6_routing_header() calculates the byte offset from the beginning of the
extention header.

In my opinion, ipv6_routing_header() must calculates the byte offset from
the beginning of the
IPv6 packet.

Is this right ?

bye.
