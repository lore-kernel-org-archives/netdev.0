From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net: dsa: mv88e6xxx: use setup_timer to simplify the code
Date: Sat, 22 Oct 2016 14:28:00 +0000
Message-ID: <1477146480-28003-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35909 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935471AbcJVO2O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2016 10:28:14 -0400
Received: by mail-pf0-f193.google.com with SMTP id r16so11472451pfg.3
        for <netdev@vger.kernel.org>; Sat, 22 Oct 2016 07:28:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Use setup_timer function instead of initializing timer with the function
and data fields.

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index ac03297..52d29b8 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -639,9 +639,8 @@ static void mv88e6xxx_ppu_state_init(struct mv88e6xxx_chip *chip)
 {
 	mutex_init(&chip->ppu_mutex);
 	INIT_WORK(&chip->ppu_work, mv88e6xxx_ppu_reenable_work);
-	init_timer(&chip->ppu_timer);
-	chip->ppu_timer.data = (unsigned long)chip;
-	chip->ppu_timer.function = mv88e6xxx_ppu_reenable_timer;
+	setup_timer(&chip->ppu_timer, mv88e6xxx_ppu_reenable_timer,
+		    (unsigned long)chip);
 }
 
 static void mv88e6xxx_ppu_state_destroy(struct mv88e6xxx_chip *chip)
