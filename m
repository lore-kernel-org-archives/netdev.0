From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] tcp: '< 0' test on unsigned
Date: Sun, 01 Mar 2009 22:09:29 +0100
Message-ID: <49AAF989.8070000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:34896 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754785AbZCAVJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2009 16:09:31 -0500
Received: by nf-out-0910.google.com with SMTP id d21so463102nfb.21
        for <netdev@vger.kernel.org>; Sun, 01 Mar 2009 13:09:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

or should this be fixed, with

        if (!buf || len > x)

if so, what should x be?

This patch wasn't tested in any way.
------------------------------>8-------------8<---------------------------------
len is unsigned, so the '< 0' test won't work.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index 25524d4..0b9d63f 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -167,7 +167,7 @@ static ssize_t tcpprobe_read(struct file *file, char __user *buf,
 {
 	int error = 0, cnt = 0;
 
-	if (!buf || len < 0)
+	if (!buf || (ssize_t)len < 0)
 		return -EINVAL;
 
 	while (cnt < len) {
