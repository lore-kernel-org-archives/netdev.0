From: David Sterba <dsterba@suse.cz>
Subject: [PATCH v2] tg3: fix return value check in tg3_read_vpd()
Date: Wed, 29 Dec 2010 14:40:31 +0100
Message-ID: <1293630031-27372-1-git-send-email-dsterba@suse.cz>
References: <201012291417.24424.dsterba@suse.cz>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Sterba <dsterba@suse.cz>,
	Michael Chan <mchan@broadcom.com>
To: mcarlson@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201012291417.24424.dsterba@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Besides -ETIMEDOUT and -EINTR, pci_read_vpd may return other error
values like -ENODEV or -EINVAL which are ignored due to the buggy
check, but the data are not read from VPD anyway and this is checked
subsequently with at most 3 needless loop iterations. This does not
show up as a runtime bug.

CC: Matt Carlson <mcarlson@broadcom.com>
CC: Michael Chan <mchan@broadcom.com>
Signed-off-by: David Sterba <dsterba@suse.cz>
---
 drivers/net/tg3.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 30ccbb6..6f97b7b 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -12658,7 +12658,7 @@ static void __devinit tg3_read_vpd(struct tg3 *tp)
 			cnt = pci_read_vpd(tp->pdev, pos,
 					   TG3_NVM_VPD_LEN - pos,
 					   &vpd_data[pos]);
-			if (cnt == -ETIMEDOUT || -EINTR)
+			if (cnt == -ETIMEDOUT || cnt == -EINTR)
 				cnt = 0;
 			else if (cnt < 0)
 				goto out_not_found;
-- 
1.7.4.rc0
