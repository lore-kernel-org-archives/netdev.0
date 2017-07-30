From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 6/6] tcp: remove unused mib counters
Date: Sun, 30 Jul 2017 03:57:23 +0200
Message-ID: <20170730015723.25587-7-fw@strlen.de>
References: <20170730015723.25587-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:45076 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753673AbdG3B50 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2017 21:57:26 -0400
In-Reply-To: <20170730015723.25587-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

was used by tcp prequeue and header prediction.
TCPFORWARDRETRANS use was removed in january.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/uapi/linux/snmp.h | 9 ---------
 net/ipv4/proc.c           | 9 ---------
 2 files changed, 18 deletions(-)

diff --git a/include/uapi/linux/snmp.h b/include/uapi/linux/snmp.h
index d85693295798..b3f346fb9fe3 100644
--- a/include/uapi/linux/snmp.h
+++ b/include/uapi/linux/snmp.h
@@ -184,14 +184,7 @@ enum
 	LINUX_MIB_DELAYEDACKLOST,		/* DelayedACKLost */
 	LINUX_MIB_LISTENOVERFLOWS,		/* ListenOverflows */
 	LINUX_MIB_LISTENDROPS,			/* ListenDrops */
-	LINUX_MIB_TCPPREQUEUED,			/* TCPPrequeued */
-	LINUX_MIB_TCPDIRECTCOPYFROMBACKLOG,	/* TCPDirectCopyFromBacklog */
-	LINUX_MIB_TCPDIRECTCOPYFROMPREQUEUE,	/* TCPDirectCopyFromPrequeue */
-	LINUX_MIB_TCPPREQUEUEDROPPED,		/* TCPPrequeueDropped */
-	LINUX_MIB_TCPHPHITS,			/* TCPHPHits */
-	LINUX_MIB_TCPHPHITSTOUSER,		/* TCPHPHitsToUser */
 	LINUX_MIB_TCPPUREACKS,			/* TCPPureAcks */
-	LINUX_MIB_TCPHPACKS,			/* TCPHPAcks */
 	LINUX_MIB_TCPRENORECOVERY,		/* TCPRenoRecovery */
 	LINUX_MIB_TCPSACKRECOVERY,		/* TCPSackRecovery */
 	LINUX_MIB_TCPSACKRENEGING,		/* TCPSACKReneging */
@@ -208,14 +201,12 @@ enum
 	LINUX_MIB_TCPSACKFAILURES,		/* TCPSackFailures */
 	LINUX_MIB_TCPLOSSFAILURES,		/* TCPLossFailures */
 	LINUX_MIB_TCPFASTRETRANS,		/* TCPFastRetrans */
-	LINUX_MIB_TCPFORWARDRETRANS,		/* TCPForwardRetrans */
 	LINUX_MIB_TCPSLOWSTARTRETRANS,		/* TCPSlowStartRetrans */
 	LINUX_MIB_TCPTIMEOUTS,			/* TCPTimeouts */
 	LINUX_MIB_TCPLOSSPROBES,		/* TCPLossProbes */
 	LINUX_MIB_TCPLOSSPROBERECOVERY,		/* TCPLossProbeRecovery */
 	LINUX_MIB_TCPRENORECOVERYFAIL,		/* TCPRenoRecoveryFail */
 	LINUX_MIB_TCPSACKRECOVERYFAIL,		/* TCPSackRecoveryFail */
-	LINUX_MIB_TCPSCHEDULERFAILED,		/* TCPSchedulerFailed */
 	LINUX_MIB_TCPRCVCOLLAPSED,		/* TCPRcvCollapsed */
 	LINUX_MIB_TCPDSACKOLDSENT,		/* TCPDSACKOldSent */
 	LINUX_MIB_TCPDSACKOFOSENT,		/* TCPDSACKOfoSent */
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 43eb6567b3a0..b6d3fe03feb3 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -206,14 +206,7 @@ static const struct snmp_mib snmp4_net_list[] = {
 	SNMP_MIB_ITEM("DelayedACKLost", LINUX_MIB_DELAYEDACKLOST),
 	SNMP_MIB_ITEM("ListenOverflows", LINUX_MIB_LISTENOVERFLOWS),
 	SNMP_MIB_ITEM("ListenDrops", LINUX_MIB_LISTENDROPS),
-	SNMP_MIB_ITEM("TCPPrequeued", LINUX_MIB_TCPPREQUEUED),
-	SNMP_MIB_ITEM("TCPDirectCopyFromBacklog", LINUX_MIB_TCPDIRECTCOPYFROMBACKLOG),
-	SNMP_MIB_ITEM("TCPDirectCopyFromPrequeue", LINUX_MIB_TCPDIRECTCOPYFROMPREQUEUE),
-	SNMP_MIB_ITEM("TCPPrequeueDropped", LINUX_MIB_TCPPREQUEUEDROPPED),
-	SNMP_MIB_ITEM("TCPHPHits", LINUX_MIB_TCPHPHITS),
-	SNMP_MIB_ITEM("TCPHPHitsToUser", LINUX_MIB_TCPHPHITSTOUSER),
 	SNMP_MIB_ITEM("TCPPureAcks", LINUX_MIB_TCPPUREACKS),
-	SNMP_MIB_ITEM("TCPHPAcks", LINUX_MIB_TCPHPACKS),
 	SNMP_MIB_ITEM("TCPRenoRecovery", LINUX_MIB_TCPRENORECOVERY),
 	SNMP_MIB_ITEM("TCPSackRecovery", LINUX_MIB_TCPSACKRECOVERY),
 	SNMP_MIB_ITEM("TCPSACKReneging", LINUX_MIB_TCPSACKRENEGING),
@@ -230,14 +223,12 @@ static const struct snmp_mib snmp4_net_list[] = {
 	SNMP_MIB_ITEM("TCPSackFailures", LINUX_MIB_TCPSACKFAILURES),
 	SNMP_MIB_ITEM("TCPLossFailures", LINUX_MIB_TCPLOSSFAILURES),
 	SNMP_MIB_ITEM("TCPFastRetrans", LINUX_MIB_TCPFASTRETRANS),
-	SNMP_MIB_ITEM("TCPForwardRetrans", LINUX_MIB_TCPFORWARDRETRANS),
 	SNMP_MIB_ITEM("TCPSlowStartRetrans", LINUX_MIB_TCPSLOWSTARTRETRANS),
 	SNMP_MIB_ITEM("TCPTimeouts", LINUX_MIB_TCPTIMEOUTS),
 	SNMP_MIB_ITEM("TCPLossProbes", LINUX_MIB_TCPLOSSPROBES),
 	SNMP_MIB_ITEM("TCPLossProbeRecovery", LINUX_MIB_TCPLOSSPROBERECOVERY),
 	SNMP_MIB_ITEM("TCPRenoRecoveryFail", LINUX_MIB_TCPRENORECOVERYFAIL),
 	SNMP_MIB_ITEM("TCPSackRecoveryFail", LINUX_MIB_TCPSACKRECOVERYFAIL),
-	SNMP_MIB_ITEM("TCPSchedulerFailed", LINUX_MIB_TCPSCHEDULERFAILED),
 	SNMP_MIB_ITEM("TCPRcvCollapsed", LINUX_MIB_TCPRCVCOLLAPSED),
 	SNMP_MIB_ITEM("TCPDSACKOldSent", LINUX_MIB_TCPDSACKOLDSENT),
 	SNMP_MIB_ITEM("TCPDSACKOfoSent", LINUX_MIB_TCPDSACKOFOSENT),
-- 
2.13.0
