From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] ss: add fastopen support
Date: Fri, 29 Mar 2013 13:51:57 -0700
Message-ID: <1364590317.5113.63.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:65190 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756894Ab3C2UwB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 16:52:01 -0400
Received: by mail-pd0-f181.google.com with SMTP id q10so392622pdj.26
        for <netdev@vger.kernel.org>; Fri, 29 Mar 2013 13:52:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

ss -i can output "fastopen" attribute if socket used Fast Open

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 include/netinet/tcp.h |    5 +++--
 misc/ss.c             |    2 ++
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/netinet/tcp.h b/include/netinet/tcp.h
index 3f890a1..ba79c63 100644
--- a/include/netinet/tcp.h
+++ b/include/netinet/tcp.h
@@ -171,8 +171,9 @@ enum
 # define TCPI_OPT_TIMESTAMPS	1
 # define TCPI_OPT_SACK		2
 # define TCPI_OPT_WSCALE	4
-# define TCPI_OPT_ECN		8
-# define TCPI_OPT_ECN_SEEN	16
+# define TCPI_OPT_ECN		8 /* ECN was negociated at TCP session init */
+# define TCPI_OPT_ECN_SEEN	16 /* we received at least one packet with ECT */
+# define TCPI_OPT_SYN_DATA	32 /* SYN-ACK acked data in SYN sent or rcvd */
 
 /* Values for tcpi_state.  */
 enum tcp_ca_state
diff --git a/misc/ss.c b/misc/ss.c
index da9d32c..b7bcd80 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1392,6 +1392,8 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r)
 				printf(" ecn");
 			if (info->tcpi_options & TCPI_OPT_ECN_SEEN)
 				printf(" ecnseen");
+			if (info->tcpi_options & TCPI_OPT_SYN_DATA)
+				printf(" fastopen");
 		}
 
 		if (tb[INET_DIAG_CONG])
