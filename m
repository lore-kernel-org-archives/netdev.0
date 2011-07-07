From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for July 7 (net/af_packet)
Date: Thu, 07 Jul 2011 08:18:39 -0700 (PDT)
Message-ID: <20110707.081839.2119597618388053074.davem@davemloft.net>
References: <20110707172544.867b980a1196db005b577c14@canb.auug.org.au>
	<20110707081202.6dddcbce.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110707081202.6dddcbce.randy.dunlap@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Thu, 7 Jul 2011 08:12:02 -0700

> On Thu, 7 Jul 2011 17:25:44 +1000 Stephen Rothwell wrote:
> 
>> Hi all,
>> 
>> The next linux-next release will (probably) be next-20110718.
>> 
>> Changes since 20110706:
> 
> 
> When CONFIG_INET is not enabled:
> 
> af_packet.c:(.text+0x3d130): undefined reference to `ip_defrag'
> or
> ERROR: "ip_defrag" [net/packet/af_packet.ko] undefined!

Sorry about that, fixed thusly:

--------------------
packet: Fix build with INET disabled.

af_packet.c:(.text+0x3d130): undefined reference to `ip_defrag'
or
ERROR: "ip_defrag" [net/packet/af_packet.ko] undefined!

Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/packet/af_packet.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index aa4c73a..d2294ad 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -456,6 +456,7 @@ static struct sock *fanout_demux_cpu(struct packet_fanout *f, struct sk_buff *sk
 
 static struct sk_buff *fanout_check_defrag(struct sk_buff *skb)
 {
+#ifdef CONFIG_INET
 	const struct iphdr *iph;
 	u32 len;
 
@@ -486,6 +487,7 @@ static struct sk_buff *fanout_check_defrag(struct sk_buff *skb)
 			skb->rxhash = 0;
 		}
 	}
+#endif
 	return skb;
 }
 
-- 
1.7.6
