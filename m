From: "Matvejchikov Ilya" <matvejchikov@gmail.com>
Subject: [PATCH] net: A little dev_valid_name() improvement
Date: Sun, 18 Jan 2009 22:07:56 +0300
Message-ID: <8496f91a0901181107o17ee80e7h7fab67194a7bde23@mail.gmail.com>
Reply-To: matvejchikov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f20.google.com ([209.85.219.20]:37673 "EHLO
	mail-ew0-f20.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752508AbZARTNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2009 14:13:40 -0500
Received: by ewy13 with SMTP id 13so37722ewy.13
        for <netdev@vger.kernel.org>; Sun, 18 Jan 2009 11:13:38 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes redundant complexity when checking the
network device name to be valid.

Signed-off-by: Matvejchikov Ilya <matvejchikov@gmail.com>
---
 net/core/dev.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 8d67597..9c5d8f4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -760,12 +760,10 @@ struct net_device * dev_get_by_flags(struct net
*net, unsigned short if_flags, u
  */
 int dev_valid_name(const char *name)
 {
-	if (*name == '\0')
+	if (*name == '\0' || *name == '.')
 		return 0;
 	if (strlen(name) >= IFNAMSIZ)
 		return 0;
-	if (!strcmp(name, ".") || !strcmp(name, ".."))
-		return 0;

 	while (*name) {
 		if (*name == '/' || isspace(*name))
-- 
1.6.1
