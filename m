From: Luis Henriques <luis.henriques@canonical.com>
Subject: [ 3.5.y.z extended stable ] Patch "rt2x00: rt2x00pci_regbusy_read() - only print register access" has been added to staging queue
Date: Fri, 12 Apr 2013 14:51:32 +0100
Message-ID: <1365774692-13156-1-git-send-email-luis.henriques@canonical.com>
Cc: Ivo van Doorn <IvDoorn@gmail.com>,
	Gertjan van Wingerde <gwingerde@gmail.com>,
	Helmut Schaa <helmut.schaa@googlemail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com,
	netdev@vger.kernel.org,
	Luis Henriques <luis.henriques@canonical.com>,
	kernel-team@lists.ubuntu.com
To: Tim Gardner <tim.gardner@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:52498 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753307Ab3DLNvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 09:51:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a note to let you know that I have just added a patch titled

    rt2x00: rt2x00pci_regbusy_read() - only print register access

to the linux-3.5.y-queue branch of the 3.5.y.z extended stable tree 
which can be found at:

 http://kernel.ubuntu.com/git?p=ubuntu/linux.git;a=shortlog;h=refs/heads/linux-3.5.y-queue

If you, or anyone else, feels it should not be added to this tree, please 
reply to this email.

For more information about the 3.5.y.z tree, see
https://wiki.ubuntu.com/Kernel/Dev/ExtendedStable

Thanks.
-Luis

------

>From 60436d8318044c7edbf8c86446712b2b1cb835b4 Mon Sep 17 00:00:00 2001
From: Tim Gardner <tim.gardner@canonical.com>
Date: Mon, 18 Feb 2013 12:56:28 -0700
Subject: [PATCH] rt2x00: rt2x00pci_regbusy_read() - only print register access
 failure once

commit 83589b30f1e1dc9898986293c9336b8ce1705dec upstream.

BugLink: http://bugs.launchpad.net/bugs/1128840

It appears that when this register read fails it never recovers, so
I think there is no need to repeat the same error message ad infinitum.

Cc: Ivo van Doorn <IvDoorn@gmail.com>
Cc: Gertjan van Wingerde <gwingerde@gmail.com>
Cc: Helmut Schaa <helmut.schaa@googlemail.com>
Cc: "John W. Linville" <linville@tuxdriver.com>
Cc: linux-wireless@vger.kernel.org
Cc: users@rt2x00.serialmonkey.com
Cc: netdev@vger.kernel.org
Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
Signed-off-by: John W. Linville <linville@tuxdriver.com>
Signed-off-by: Luis Henriques <luis.henriques@canonical.com>
---
 drivers/net/wireless/rt2x00/rt2x00pci.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rt2x00/rt2x00pci.c b/drivers/net/wireless/rt2x00/rt2x00pci.c
index 0a4653a..1ea98a8 100644
--- a/drivers/net/wireless/rt2x00/rt2x00pci.c
+++ b/drivers/net/wireless/rt2x00/rt2x00pci.c
@@ -52,8 +52,8 @@ int rt2x00pci_regbusy_read(struct rt2x00_dev *rt2x00dev,
 		udelay(REGISTER_BUSY_DELAY);
 	}

-	ERROR(rt2x00dev, "Indirect register access failed: "
-	      "offset=0x%.08x, value=0x%.08x\n", offset, *reg);
+	printk_once(KERN_ERR "%s() Indirect register access failed: "
+	      "offset=0x%.08x, value=0x%.08x\n", __func__, offset, *reg);
 	*reg = ~0;

 	return 0;
--
1.8.1.2
