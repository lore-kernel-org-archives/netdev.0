From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] cipso: subtraction on unsigned hdr_delta
Date: Tue, 03 Mar 2009 23:23:38 +0100
Message-ID: <49ADADEA.8090306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f177.google.com ([209.85.219.177]:47715 "EHLO
	mail-ew0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758401AbZCCWXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 17:23:39 -0500
Received: by ewy25 with SMTP id 25so2534157ewy.37
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2009 14:23:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hdr_delta is unsigned, so take care not to subtract below 0.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index 7bc9929..b1d862b 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -1999,7 +1999,11 @@ void cipso_v4_sock_delattr(struct sock *sk)
 				iter++;
 		hdr_delta = opt->optlen;
 		opt->optlen = (optlen_new + 3) & ~3;
-		hdr_delta -= opt->optlen;
+
+		if (hdr_delta > opt->optlen)
+			hdr_delta -= opt->optlen;
+		else
+			hdr_delta = 0;
 	} else {
 		/* only the cipso option was present on the socket so we can
 		 * remove the entire option struct */
