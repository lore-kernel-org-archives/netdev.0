From: Florian Westphal <fw@strlen.de>
Subject: [RFC 3/3] tcp: add mib counter to track ts tsecr validation failures
Date: Thu, 18 Aug 2016 14:48:47 +0200
Message-ID: <1471524527-10029-4-git-send-email-fw@strlen.de>
References: <1471524527-10029-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:51590 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754030AbcHRNAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 09:00:09 -0400
In-Reply-To: <1471524527-10029-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

useful to detect packet drop due to enabled tcp_timestamps=2 mode.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/uapi/linux/snmp.h | 1 +
 net/ipv4/proc.c           | 1 +
 net/ipv4/tcp_input.c      | 1 +
 3 files changed, 3 insertions(+)

diff --git a/include/uapi/linux/snmp.h b/include/uapi/linux/snmp.h
index 25a9ad8..79916ca 100644
--- a/include/uapi/linux/snmp.h
+++ b/include/uapi/linux/snmp.h
@@ -280,6 +280,7 @@ enum
 	LINUX_MIB_TCPKEEPALIVE,			/* TCPKeepAlive */
 	LINUX_MIB_TCPMTUPFAIL,			/* TCPMTUPFail */
 	LINUX_MIB_TCPMTUPSUCCESS,		/* TCPMTUPSuccess */
+	LINUX_MIB_TCPTSECRFAIL,			/* TCPTSecrFail */
 	__LINUX_MIB_MAX
 };
 
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 9f665b6..e7667f8 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -302,6 +302,7 @@ static const struct snmp_mib snmp4_net_list[] = {
 	SNMP_MIB_ITEM("TCPKeepAlive", LINUX_MIB_TCPKEEPALIVE),
 	SNMP_MIB_ITEM("TCPMTUPFail", LINUX_MIB_TCPMTUPFAIL),
 	SNMP_MIB_ITEM("TCPMTUPSuccess", LINUX_MIB_TCPMTUPSUCCESS),
+	SNMP_MIB_ITEM("TCPTSecrFail", LINUX_MIB_TCPTSECRFAIL),
 	SNMP_MIB_SENTINEL
 };
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 1234244..e114777 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5287,6 +5287,7 @@ syn_challenge:
 
 	/* last step: ofo and not pure ack: check tsecr */
 	if (!tcp_validate_tsecr(sk, th)) {
+		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPTSECRFAIL);
 		goto discard;
 	}
 
-- 
2.7.3
