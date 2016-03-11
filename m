From: David Decotigny <ddecotig@gmail.com>
Subject: [ethtool PATCH v4 11/11] ethtool.c: support absence of v4 sockets
Date: Fri, 11 Mar 2016 09:58:24 -0800
Message-ID: <1457719104-39188-12-git-send-email-ddecotig@gmail.com>
References: <1457719104-39188-1-git-send-email-ddecotig@gmail.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	Joe Perches <joe@perches.com>,
	David Decotigny <decot@googlers.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:33736 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751029AbcCKR6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 12:58:45 -0500
Received: by mail-pa0-f67.google.com with SMTP id q6so9057003pav.0
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 09:58:45 -0800 (PST)
In-Reply-To: <1457719104-39188-1-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Decotigny <decot@googlers.com>


Signed-off-by: David Decotigny <decot@googlers.com>
---
 ethtool.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/ethtool.c b/ethtool.c
index 761252f..f9336e3 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -4615,6 +4615,9 @@ opt_found:
 		/* Open control socket. */
 		ctx.fd = socket(AF_INET, SOCK_DGRAM, 0);
 		if (ctx.fd < 0) {
+			ctx.fd = socket(AF_UNIX, SOCK_DGRAM, 0);
+		}
+		if (ctx.fd < 0) {
 			perror("Cannot get control socket");
 			return 70;
 		}
-- 
2.7.0.rc3.207.g0ac5344
