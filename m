From: akpm@linux-foundation.org
Subject: [patch 8/8] isdn/capi: return proper errnos on module init
Date: Wed, 14 May 2008 16:19:46 -0700
Message-ID: <200805142319.m4ENJlhA026572@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	marcin.slusarz@gmail.com, kkeil@suse.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57110 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754176AbYENXUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 19:20:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcin Slusarz <marcin.slusarz@gmail.com>

cdebug_init() is called from kcapi_init() which is module initialization
function, so it must return negative values on errors.

Signed-off-by: Marcin Slusarz <marcin.slusarz@gmail.com>
Acked-by: Karsten Keil <kkeil@suse.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/isdn/capi/capiutil.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff -puN drivers/isdn/capi/capiutil.c~isdn-capi-return-proper-errnos-on-module-init drivers/isdn/capi/capiutil.c
--- a/drivers/isdn/capi/capiutil.c~isdn-capi-return-proper-errnos-on-module-init
+++ a/drivers/isdn/capi/capiutil.c
@@ -948,17 +948,17 @@ int __init cdebug_init(void)
 {
 	g_cmsg= kmalloc(sizeof(_cmsg), GFP_KERNEL);
 	if (!g_cmsg)
-		return ENOMEM;
+		return -ENOMEM;
 	g_debbuf = kmalloc(sizeof(_cdebbuf), GFP_KERNEL);
 	if (!g_debbuf) {
 		kfree(g_cmsg);
-		return ENOMEM;
+		return -ENOMEM;
 	}
 	g_debbuf->buf = kmalloc(CDEBUG_GSIZE, GFP_KERNEL);
 	if (!g_debbuf->buf) {
 		kfree(g_cmsg);
 		kfree(g_debbuf);
-		return ENOMEM;;
+		return -ENOMEM;;
 	}
 	g_debbuf->size = CDEBUG_GSIZE;
 	g_debbuf->buf[0] = 0;
_
