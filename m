From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH net] net: rename and move busy poll mib counter
Date: Tue, 06 Aug 2013 12:52:07 +0300
Message-ID: <20130806095207.5887.2196.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Shawn Bohrer <sbohrer@rgmadvisors.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:1683 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755559Ab3HFJwK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 05:52:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the low latency mib counter to the ip section.
Rename it from low latency to busy poll.

Reported-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
---

 include/net/busy_poll.h   |    4 ++--
 include/uapi/linux/snmp.h |    2 +-
 net/ipv4/proc.c           |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/busy_poll.h b/include/net/busy_poll.h
index 8e2dfc1..1b48741 100644
--- a/include/net/busy_poll.h
+++ b/include/net/busy_poll.h
@@ -121,8 +121,8 @@ static inline bool sk_busy_loop(struct sock *sk, int nonblock)
 
 		if (rc > 0)
 			/* local bh are disabled so it is ok to use _BH */
-			NET_ADD_STATS_BH(sock_net(sk),
-					 LINUX_MIB_LOWLATENCYRXPACKETS, rc);
+			IP_ADD_STATS_BH(dev_net(napi->dev),
+					IPSTATS_MIB_BUSYPOLLRXPACKETS, rc);
 
 	} while (!nonblock && skb_queue_empty(&sk->sk_receive_queue) &&
 		 !need_resched() && !busy_loop_timeout(end_time));
diff --git a/include/uapi/linux/snmp.h b/include/uapi/linux/snmp.h
index af0a674..5575d9b 100644
--- a/include/uapi/linux/snmp.h
+++ b/include/uapi/linux/snmp.h
@@ -51,6 +51,7 @@ enum
 	IPSTATS_MIB_INBCASTOCTETS,		/* InBcastOctets */
 	IPSTATS_MIB_OUTBCASTOCTETS,		/* OutBcastOctets */
 	IPSTATS_MIB_CSUMERRORS,			/* InCsumErrors */
+	IPSTATS_MIB_BUSYPOLLRXPACKETS,		/* BusyPollRxPackets */
 	__IPSTATS_MIB_MAX
 };
 
@@ -253,7 +254,6 @@ enum
 	LINUX_MIB_TCPFASTOPENLISTENOVERFLOW,	/* TCPFastOpenListenOverflow */
 	LINUX_MIB_TCPFASTOPENCOOKIEREQD,	/* TCPFastOpenCookieReqd */
 	LINUX_MIB_TCPSPURIOUS_RTX_HOSTQUEUES, /* TCPSpuriousRtxHostQueues */
-	LINUX_MIB_LOWLATENCYRXPACKETS,		/* LowLatencyRxPackets */
 	__LINUX_MIB_MAX
 };
 
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 6577a11..3c54a63 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -108,6 +108,7 @@ static const struct snmp_mib snmp4_ipstats_list[] = {
 	SNMP_MIB_ITEM("FragOKs", IPSTATS_MIB_FRAGOKS),
 	SNMP_MIB_ITEM("FragFails", IPSTATS_MIB_FRAGFAILS),
 	SNMP_MIB_ITEM("FragCreates", IPSTATS_MIB_FRAGCREATES),
+	SNMP_MIB_ITEM("BusyPollRxPackets", IPSTATS_MIB_BUSYPOLLRXPACKETS),
 	SNMP_MIB_SENTINEL
 };
 
@@ -273,7 +274,6 @@ static const struct snmp_mib snmp4_net_list[] = {
 	SNMP_MIB_ITEM("TCPFastOpenListenOverflow", LINUX_MIB_TCPFASTOPENLISTENOVERFLOW),
 	SNMP_MIB_ITEM("TCPFastOpenCookieReqd", LINUX_MIB_TCPFASTOPENCOOKIEREQD),
 	SNMP_MIB_ITEM("TCPSpuriousRtxHostQueues", LINUX_MIB_TCPSPURIOUS_RTX_HOSTQUEUES),
-	SNMP_MIB_ITEM("LowLatencyRxPackets", LINUX_MIB_LOWLATENCYRXPACKETS),
 	SNMP_MIB_SENTINEL
 };
 
