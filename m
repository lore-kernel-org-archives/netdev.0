From: cranium 2003 <cranium.2003@gmail.com>
Subject: checksum calculation in ip packet forwarding
Date: Sun, 30 Jan 2005 18:39:07 +0530
Message-ID: <1d55641b05013005097df61788@mail.gmail.com>
Reply-To: cranium 2003 <cranium.2003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,
1) How Router knows destinations mtu. In IP forwarding case following
function is used that checks pmtu value to decide whether outgoing
packet is required to fragment a packet or not?
static inline int ip_send(struct sk_buff *skb)
{
	if (skb->len > skb->dst->pmtu)
		return ip_fragment(skb, ip_finish_output);
	else
		return ip_finish_output(skb);
}

2) Can anybody help me how following function works in calcualting checksum?
static inline int ip_decrease_ttl(struct iphdr *iph)
{
	u32 check = iph->check;
	check += __constant_htons(0x0100);
	iph->check = check + (check>=0xFFFF);
	return --iph->ttl;
}
regards,
cranium
