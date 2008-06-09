From: akpm@linux-foundation.org
Subject: [patch 3/4] isdn divas: fix proc creation
Date: Mon, 09 Jun 2008 16:32:00 -0700
Message-ID: <200806092332.m59NW0wf014559@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	adobriyan@gmail.com, kkeil@suse.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38498 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755725AbYFIXcG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2008 19:32:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>

1. creating proc entry and not saving pointer to PDE and checking it
   is not going to work.
2. if proc entry wasn't created, no reason to remove it on error path.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Karsten Keil <kkeil@suse.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/isdn/hardware/eicon/divasmain.c |    1 -
 drivers/isdn/hardware/eicon/divasproc.c |    4 ++--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff -puN drivers/isdn/hardware/eicon/divasmain.c~isdn-divas-fix-proc-creation drivers/isdn/hardware/eicon/divasmain.c
--- a/drivers/isdn/hardware/eicon/divasmain.c~isdn-divas-fix-proc-creation
+++ a/drivers/isdn/hardware/eicon/divasmain.c
@@ -808,7 +808,6 @@ static int DIVA_INIT_FUNCTION divas_init
 
 	if (!create_divas_proc()) {
 #ifdef MODULE
-		remove_divas_proc();
 		divas_unregister_chrdev();
 		divasfunc_exit();
 #endif
diff -puN drivers/isdn/hardware/eicon/divasproc.c~isdn-divas-fix-proc-creation drivers/isdn/hardware/eicon/divasproc.c
--- a/drivers/isdn/hardware/eicon/divasproc.c~isdn-divas-fix-proc-creation
+++ a/drivers/isdn/hardware/eicon/divasproc.c
@@ -125,8 +125,8 @@ static const struct file_operations diva
 
 int create_divas_proc(void)
 {
-	proc_create(divas_proc_name, S_IFREG | S_IRUGO, proc_net_eicon,
-		    &divas_fops);
+	divas_proc_entry = proc_create(divas_proc_name, S_IFREG | S_IRUGO,
+					proc_net_eicon, &divas_fops);
 	if (!divas_proc_entry)
 		return (0);
 
_
