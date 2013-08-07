From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH net v2] net: rename  busy poll MIB counter
Date: Wed, 07 Aug 2013 11:33:25 +0300
Message-ID: <20130807083324.27322.99300.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Shawn Bohrer <sbohrer@rgmadvisors.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rename mib counter from "low latency" to "busy poll"

v1 also moved the counter to the ip MIB (suggested by Shawn Bohrer)
Eric Dumazet suggested that the current location is better.

So v2 just renames the counter to fit the new naming convention.

Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
---

 include/net/busy_poll.h   |    2 +-
 include/uapi/linux/snmp.h |    2 +-
 net/ipv4/proc.c           |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/busy_poll.h b/include/net/busy_poll.h
index f18b919..7a7abe9 100644
--- a/include/net/busy_poll.h
+++ b/include/net/busy_poll.h
@@ -122,7 +122,7 @@ static inline bool sk_busy_loop(struct sock *sk, int nonblock)
 		if (rc > 0)
 			/* local bh are disabled so it is ok to use _BH */
 			NET_ADD_STATS_BH(sock_net(sk),
-					 LINUX_MIB_LOWLATENCYRXPACKETS, rc);
+					 LINUX_MIB_BUSYPOLLRXPACKETS, rc);
 
 	} while (!nonblock && skb_queue_empty(&sk->sk_receive_queue) &&
 		 !need_resched() && !busy_loop_timeout(end_time));
diff --git a/include/uapi/linux/snmp.h b/include/uapi/linux/snmp.h
index af0a674..a1356d3 100644
--- a/include/uapi/linux/snmp.h
+++ b/include/uapi/linux/snmp.h
@@ -253,7 +253,7 @@ enum
 	LINUX_MIB_TCPFASTOPENLISTENOVERFLOW,	/* TCPFastOpenListenOverflow */
 	LINUX_MIB_TCPFASTOPENCOOKIEREQD,	/* TCPFastOpenCookieReqd */
 	LINUX_MIB_TCPSPURIOUS_RTX_HOSTQUEUES, /* TCPSpuriousRtxHostQueues */
-	LINUX_MIB_LOWLATENCYRXPACKETS,		/* LowLatencyRxPackets */
+	LINUX_MIB_BUSYPOLLRXPACKETS,		/* BusyPollRxPackets */
 	__LINUX_MIB_MAX
 };
 
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 6577a11..463bd12 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -273,7 +273,7 @@ static const struct snmp_mib snmp4_net_list[] = {
 	SNMP_MIB_ITEM("TCPFastOpenListenOverflow", LINUX_MIB_TCPFASTOPENLISTENOVERFLOW),
 	SNMP_MIB_ITEM("TCPFastOpenCookieReqd", LINUX_MIB_TCPFASTOPENCOOKIEREQD),
 	SNMP_MIB_ITEM("TCPSpuriousRtxHostQueues", LINUX_MIB_TCPSPURIOUS_RTX_HOSTQUEUES),
-	SNMP_MIB_ITEM("LowLatencyRxPackets", LINUX_MIB_LOWLATENCYRXPACKETS),
+	SNMP_MIB_ITEM("BusyPollRxPackets", LINUX_MIB_BUSYPOLLRXPACKETS),
 	SNMP_MIB_SENTINEL
 };
 
