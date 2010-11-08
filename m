From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH 07/17][trivial] net, wireless: Remove unnecessary casts of
 void ptr returning alloc function return values
Date: Tue, 9 Nov 2010 00:09:13 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1011082330390.23697@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: trivial@kernel.org, Ulrich Kunitz <kune@deine-taler.de>,
	Daniel Drake <dsd@gentoo.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:39364 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751727Ab0KHXUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 18:20:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The [vk][cmz]alloc(_node) family of functions return void pointers which
it's completely unnecessary/pointless to cast to other pointer types since
that happens implicitly.

This patch removes such casts from drivers/net/


Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 zd_chip.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)
diff --git a/drivers/net/wireless/zd1211rw/zd_chip.c b/drivers/net/wireless/zd1211rw/zd_chip.c
index 87a95bc..dfcebed 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.c
+++ b/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -117,8 +117,7 @@ int zd_ioread32v_locked(struct zd_chip *chip, u32 *values, const zd_addr_t *addr
 
 	/* Allocate a single memory block for values and addresses. */
 	count16 = 2*count;
-	a16 = (zd_addr_t *) kmalloc(count16 * (sizeof(zd_addr_t) + sizeof(u16)),
-		                   GFP_KERNEL);
+	a16 = kmalloc(count16 * (sizeof(zd_addr_t) + sizeof(u16)), GFP_KERNEL);
 	if (!a16) {
 		dev_dbg_f(zd_chip_dev(chip),
 			  "error ENOMEM in allocation of a16\n");



-- 
Jesper Juhl <jj@chaosbits.net>             http://www.chaosbits.net/
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

