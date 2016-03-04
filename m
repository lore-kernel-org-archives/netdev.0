From: David Decotigny <ddecotig@gmail.com>
Subject: [ethtool PATCH v2 12/12] ethtool.c: use v6 socket when v4 is not available
Date: Thu,  3 Mar 2016 20:23:25 -0800
Message-ID: <1457065405-19049-13-git-send-email-ddecotig@gmail.com>
References: <1457065405-19049-1-git-send-email-ddecotig@gmail.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	David Decotigny <decot@googlers.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34562 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755655AbcCDEXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 23:23:50 -0500
Received: by mail-pf0-f194.google.com with SMTP id 184so2508125pff.1
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 20:23:50 -0800 (PST)
In-Reply-To: <1457065405-19049-1-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Decotigny <decot@googlers.com>


Signed-off-by: David Decotigny <decot@googlers.com>
---
 ethtool.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/ethtool.c b/ethtool.c
index e1acf09..4daf538 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -4618,6 +4618,9 @@ opt_found:
 		/* Open control socket. */
 		ctx.fd = socket(AF_INET, SOCK_DGRAM, 0);
 		if (ctx.fd < 0) {
+			ctx.fd = socket(AF_INET6, SOCK_DGRAM, 0);
+		}
+		if (ctx.fd < 0) {
 			perror("Cannot get control socket");
 			return 70;
 		}
-- 
2.7.0.rc3.207.g0ac5344
