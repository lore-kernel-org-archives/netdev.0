From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] ss: report ecnseen
Date: Wed, 12 Oct 2011 05:18:21 +0200
Message-ID: <1318389501.3686.8.camel@edumazet-laptop>
References: <20110916103031.7f22b35f@nehalam.linuxnetplumber.net>
	 <20111011165908.0d6ed7de@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:65315 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752401Ab1JLDS1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2011 23:18:27 -0400
Received: by wyg34 with SMTP id 34so230807wyg.19
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2011 20:18:26 -0700 (PDT)
In-Reply-To: <20111011165908.0d6ed7de@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support ECNSEEN reporting in ss command.

ESTAB      0      0           10.170.73.123:4900
10.170.73.125:51001    uid:501 ino:385994 sk:f31e5f00
	 mem:(r0,w0,f0,t0) ts sack ecn ecnseen bic wscale:8,8 rto:210
rtt:18.75/15 ato:40 cwnd:10 send 69.9Mbps rcv_space:32768

"ecn" means TCP session negociated ECN capability at setup time

"ecnseen" at least one frame with ECT(0) or ECT(1) or ECN (IP layer) was
received from peer.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/netinet/tcp.h |    1 +
 misc/ss.c             |    2 ++
 2 files changed, 3 insertions(+)

diff --git a/include/netinet/tcp.h b/include/netinet/tcp.h
index 282b29c..95a4fe6 100644
--- a/include/netinet/tcp.h
+++ b/include/netinet/tcp.h
@@ -172,6 +172,7 @@ enum
 # define TCPI_OPT_SACK		2
 # define TCPI_OPT_WSCALE	4
 # define TCPI_OPT_ECN		8
+# define TCPI_OPT_ECNSEEN	16
 
 /* Values for tcpi_state.  */
 enum tcp_ca_state
diff --git a/misc/ss.c b/misc/ss.c
index b00841b..778bf0a 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1357,6 +1357,8 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r)
 				printf(" sack");
 			if (info->tcpi_options & TCPI_OPT_ECN)
 				printf(" ecn");
+			if (info->tcpi_options & TCPI_OPT_ECNSEEN)
+				printf(" ecnseen");
 		}
 
 		if (tb[INET_DIAG_CONG])
