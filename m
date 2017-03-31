From: Nicolas Iooss <nicolas.iooss_linux@m4x.org>
Subject: Pointer type of _arp in __skb_flow_dissect()
Date: Fri, 31 Mar 2017 20:53:10 +0200
Message-ID: <9bb97603-3b86-73cb-8ed8-c421055138a6@m4x.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Simon Horman <simon.horman@netronome.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Linux 4.11-rc4 contains the following code in function
__skb_flow_dissect(), file net/core/flow_dissector.c:

	const struct arphdr *arp;
	struct arphdr *_arp;

	arp = __skb_header_pointer(skb, nhoff, sizeof(_arp), data,
				   hlen, &_arp);


Here _arp and arp are both pointers to arphdr structures. In other calls
to __skb_header_pointer(), the buffer argument (_arp here) would have
been a struct instead of a pointer. What makes ARP packets different in
__skb_flow_dissect()?

Thanks,
Nicolas

PS: the code which I am curious about seems to have been introduced in
4.11-rc1 with commit 55733350e5e8 ("flow disector: ARP support")
