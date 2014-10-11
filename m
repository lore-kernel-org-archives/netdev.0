From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 02/12] isdn/gigaset: make sure controller name is null terminated
Date: Sat, 11 Oct 2014 13:46:29 +0200 (CEST)
Message-ID: <b3f7480f2ec6f22d26367abbbacd657cf70f1c05.1413021630.git.tilman@imap.cc>
References: <cover.1413021630.git.tilman@imap.cc>
Cc: David Miller <davem@davemloft.net>, Dave Jones <davej@redhat.com>,
	Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([89.1.7.7]:42120 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752097AbaJKLrD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Oct 2014 07:47:03 -0400
In-Reply-To: <cover.1413021630.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In gigaset_isdn_regdev, the name field may not have a null terminator
if the source string's length is equal to the buffer size.
Fix by zero filling the structure and excluding the last byte of the
name field from the copy.

Spotted with Coverity.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/capi.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/gigaset/capi.c b/drivers/isdn/gigaset/capi.c
index a2eabe9..044392c 100644
--- a/drivers/isdn/gigaset/capi.c
+++ b/drivers/isdn/gigaset/capi.c
@@ -2358,7 +2358,7 @@ int gigaset_isdn_regdev(struct cardstate *cs, const char *isdnid)
 	struct gigaset_capi_ctr *iif;
 	int rc;
 
-	iif = kmalloc(sizeof(*iif), GFP_KERNEL);
+	iif = kzalloc(sizeof(*iif), GFP_KERNEL);
 	if (!iif) {
 		pr_err("%s: out of memory\n", __func__);
 		return -ENOMEM;
@@ -2367,7 +2367,7 @@ int gigaset_isdn_regdev(struct cardstate *cs, const char *isdnid)
 	/* prepare controller structure */
 	iif->ctr.owner         = THIS_MODULE;
 	iif->ctr.driverdata    = cs;
-	strncpy(iif->ctr.name, isdnid, sizeof(iif->ctr.name));
+	strncpy(iif->ctr.name, isdnid, sizeof(iif->ctr.name) - 1);
 	iif->ctr.driver_name   = "gigaset";
 	iif->ctr.load_firmware = NULL;
 	iif->ctr.reset_ctr     = NULL;
-- 
1.9.2.459.g68773ac
