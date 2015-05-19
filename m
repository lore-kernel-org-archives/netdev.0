From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] inet: properly align icsk_ca_priv
Date: Mon, 18 May 2015 17:06:14 -0700
Message-ID: <1431993974.621.50.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431894670-12609-1-git-send-email-kennetkl@ifi.uio.no>
	 <20150518151648.6d33128c@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>,
	netdev@vger.kernel.org, David Hayes <davihay@ifi.uio.no>,
	Yuchung Cheng <ycheng@google.com>,
	Andreas Petlund <apetlund@simula.no>
To: Stephen Hemminger <stephen@networkplumber.org>,
	Fan Du <fan.du@intel.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:34565 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbbESAGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 20:06:17 -0400
Received: by igbhj9 with SMTP id hj9so20133901igb.1
        for <netdev@vger.kernel.org>; Mon, 18 May 2015 17:06:17 -0700 (PDT)
In-Reply-To: <20150518151648.6d33128c@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

tcp_illinois and upcoming tcp_cdg require 64bit alignment of
icsk_ca_priv

x86 does not care, but other architectures might.

Fixes: 05cbc0db03e82 ("ipv4: Create probe timer for tcp PMTU as per RFC4821")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Fan Du <fan.du@intel.com>
---
 include/net/inet_connection_sock.h |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 48a8158235874b1625c65651b0bd92eedd999fe5..497bc14cdb85f4f8b33da8fbe7aba9d491df50e2 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -129,9 +129,10 @@ struct inet_connection_sock {
 
 		u32		  probe_timestamp;
 	} icsk_mtup;
-	u32			  icsk_ca_priv[16];
 	u32			  icsk_user_timeout;
-#define ICSK_CA_PRIV_SIZE	(16 * sizeof(u32))
+
+	u64			  icsk_ca_priv[64 / sizeof(u64)];
+#define ICSK_CA_PRIV_SIZE      (8 * sizeof(u64))
 };
 
 #define ICSK_TIME_RETRANS	1	/* Retransmit timer */
