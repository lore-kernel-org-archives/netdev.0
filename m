From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: Removes wrong assertions
Date: Wed, 13 Sep 2006 02:41:35 +0100 (BST)
Message-ID: <20060913014135.910927B40A0@zog.reactivated.net>
Cc: kune@deine-taler.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout01-winn.ispmail.ntl.com ([81.103.221.47]:35460 "EHLO
	mtaout01-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1030479AbWIMBgr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Sep 2006 21:36:47 -0400
To: linville@tuxdriver.com
Cc: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ulrich Kunitz <kune@deine-taler.de>

Checking whether a mutex is not locked directly before
mutex_lock() is called, doesn't make sense. The whole point of
mutex_lock() is to block, if the mutex is locked.

Signed-off-by: Ulrich Kunitz <kune@deine-taler.de>
Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 zd_chip.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_chip.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_chip.c
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -249,7 +249,6 @@ int zd_ioread16(struct zd_chip *chip, zd
 {
 	int r;
 
-	ZD_ASSERT(!mutex_is_locked(&chip->mutex));
 	mutex_lock(&chip->mutex);
 	r = zd_ioread16_locked(chip, value, addr);
 	mutex_unlock(&chip->mutex);
@@ -260,7 +259,6 @@ int zd_ioread32(struct zd_chip *chip, zd
 {
 	int r;
 
-	ZD_ASSERT(!mutex_is_locked(&chip->mutex));
 	mutex_lock(&chip->mutex);
 	r = zd_ioread32_locked(chip, value, addr);
 	mutex_unlock(&chip->mutex);
@@ -271,7 +269,6 @@ int zd_iowrite16(struct zd_chip *chip, z
 {
 	int r;
 
-	ZD_ASSERT(!mutex_is_locked(&chip->mutex));
 	mutex_lock(&chip->mutex);
 	r = zd_iowrite16_locked(chip, value, addr);
 	mutex_unlock(&chip->mutex);
@@ -282,7 +279,6 @@ int zd_iowrite32(struct zd_chip *chip, z
 {
 	int r;
 
-	ZD_ASSERT(!mutex_is_locked(&chip->mutex));
 	mutex_lock(&chip->mutex);
 	r = zd_iowrite32_locked(chip, value, addr);
 	mutex_unlock(&chip->mutex);
@@ -294,7 +290,6 @@ int zd_ioread32v(struct zd_chip *chip, c
 {
 	int r;
 
-	ZD_ASSERT(!mutex_is_locked(&chip->mutex));
 	mutex_lock(&chip->mutex);
 	r = zd_ioread32v_locked(chip, values, addresses, count);
 	mutex_unlock(&chip->mutex);
@@ -306,7 +301,6 @@ int zd_iowrite32a(struct zd_chip *chip, 
 {
 	int r;
 
-	ZD_ASSERT(!mutex_is_locked(&chip->mutex));
 	mutex_lock(&chip->mutex);
 	r = zd_iowrite32a_locked(chip, ioreqs, count);
 	mutex_unlock(&chip->mutex);
