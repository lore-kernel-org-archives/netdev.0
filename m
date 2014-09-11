From: Sanjeev Sharma <sanjeev_sharma@mentor.com>
Subject: [PATCH v2] zd1211rw: replace ZD_ASSERT with lockdep_assert_held()
Date: Thu, 11 Sep 2014 15:39:39 +0530
Message-ID: <1410430179-19944-1-git-send-email-sanjeev_sharma@mentor.com>
References: <1410418407.1825.0.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kune@deine-taler.de>, <linux-wireless@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Sanjeev Sharma <sanjeev_sharma@mentor.com>,
	Sanjeev Sharma <Sanjeev_Sharma@mentor.com>
To: <dsd@gentoo.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410418407.1825.0.camel@jlt4.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

on some architecture spin_is_locked() always return false in
uniprocessor configuration and therefore it would be advise
to replace with lockdep_assert_held().

Signed-off-by: Sanjeev Sharma <Sanjeev_Sharma@mentor.com>
---
Changes in v2:
  - corrected the typo

 drivers/net/wireless/zd1211rw/zd_mac.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index e7af261..adce2ee 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -235,7 +235,7 @@ void zd_mac_clear(struct zd_mac *mac)
 {
 	flush_workqueue(zd_workqueue);
 	zd_chip_clear(&mac->chip);
-	ZD_ASSERT(!spin_is_locked(&mac->lock));
+	lockdep_assert_held(&mac->lock);
 	ZD_MEMCLEAR(mac, sizeof(struct zd_mac));
 }
 
-- 
1.7.11.7
