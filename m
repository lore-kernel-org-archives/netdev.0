From: Ulrich Kunitz <kune@deine-taler.de>
Subject: [PATCH 4/6] zd1211rw: Remove bogus assert
Date: Tue, 01 Aug 2006 23:43:33 +0200
Message-ID: <11544686162131-git-send-email-kune@deine-taler.de>
References: <1154468615618-git-send-email-kune@deine-taler.de>
Reply-To: Ulrich Kunitz <kune@deine-taler.de>
Cc: netdev@vger.kernel.org, dsd@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:29124 "EHLO
	p15091797.pureserver.info") by vger.kernel.org with ESMTP
	id S1751080AbWHAVng (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 17:43:36 -0400
To: linville@tuxdriver.com
In-Reply-To: <1154468615618-git-send-email-kune@deine-taler.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Drake <dsd@gentoo.org>

This function is never called in interrupt context, and it doesn't
matter if it is called in IRQ context or not.

Signed-off-by: Daniel Drake <dsd@gentoo.org>
Signed-off-by: Ulrich Kunitz <kune@deine-taler.de>
---
 drivers/net/wireless/zd1211rw/zd_usb.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index c68b9f8..2e3d77e 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -325,7 +325,6 @@ static void disable_read_regs_int(struct
 {
 	struct zd_usb_interrupt *intr = &usb->intr;
 
-	ZD_ASSERT(in_interrupt());
 	spin_lock(&intr->lock);
 	intr->read_regs_enabled = 0;
 	spin_unlock(&intr->lock);
-- 
1.4.1

