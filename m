From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH] rtl8xxxu: mark symbol static where possible
Date: Wed, 26 Oct 2016 17:32:50 +0800
Message-ID: <1477474370-31383-1-git-send-email-baoyou.xie@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn,
        han.fei@zte.com.cn, tang.qiang007@zte.com.cn
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:32769 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758115AbcJZJdL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 05:33:11 -0400
Received: by mail-pf0-f175.google.com with SMTP id 197so12967071pfu.0
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 02:33:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We get 1 warning when building kernel with W=1:
drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c:1557:6: warning: no previous prototype for 'rtl8192eu_power_off' [-Wmissing-prototypes]

In fact, this function is only used in the file in which it is
declared and don't need a declaration, but can be made static.
So this patch marks this function with 'static'.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 883fd98..4d975f0 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2701,7 +2701,7 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 	return mv88e6xxx_port_write(chip, port, PORT_DEFAULT_VLAN, 0x0000);
 }
 
-int mv88e6xxx_g1_set_switch_mac(struct mv88e6xxx_chip *chip, u8 *addr)
+static int mv88e6xxx_g1_set_switch_mac(struct mv88e6xxx_chip *chip, u8 *addr)
 {
 	int err;
 
-- 
2.7.4
