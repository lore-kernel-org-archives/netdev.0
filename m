From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] bridge: provide a mtu() method for fake_dst_ops
Date: Thu, 22 Dec 2011 07:00:32 +0100
Message-ID: <1324533632.2621.35.camel@edumazet-laptop>
References: <4EF200BB.7000209@bootc.net>
	 <1324484956.2301.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EF2117F.6000803@bootc.net>
	 <1324488984.2301.45.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324490401.2301.46.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EF23BF2.4000601@bootc.net> <1324499332.2621.7.camel@edumazet-laptop>
	 <1324500775.2621.9.camel@edumazet-laptop> <4EF2568C.6040006@bootc.net>
	 <AEC29013-98F3-4A16-A88B-AD31C9E88EB8@bootc.net>
	 <1324528656.2621.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Chris Boot <bootc@bootc.net>, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1324528656.2621.19.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 618f9bc74a039da76 (net: Move mtu handling down to the protocol
depended handlers) forgot the bridge netfilter case, adding a NULL
dereference in ip_fragment().

Reported-by: Chris Boot <bootc@bootc.net>
CC: Steffen Klassert <steffen.klassert@secunet.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/bridge/br_netfilter.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index d6ec372..08757dc 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -114,12 +114,18 @@ static struct neighbour *fake_neigh_lookup(const struct dst_entry *dst, const vo
 	return NULL;
 }
 
+static unsigned int fake_mtu(const struct dst_entry *dst)
+{
+	return dst->dev->mtu;
+}
+
 static struct dst_ops fake_dst_ops = {
 	.family =		AF_INET,
 	.protocol =		cpu_to_be16(ETH_P_IP),
 	.update_pmtu =		fake_update_pmtu,
 	.cow_metrics =		fake_cow_metrics,
 	.neigh_lookup =		fake_neigh_lookup,
+	.mtu =			fake_mtu,
 };
 
 /*
