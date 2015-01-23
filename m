From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH] net: dsa/mv88e6xxx: add reg read and write debug
Date: Fri, 23 Jan 2015 16:10:36 -0500
Message-ID: <1422047436-6864-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"David S . Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This commit adds debug messages for the generic mv88e6xxx read and write
routines. The output is similar to this:

    mdio-gpio mdio-gpio.0: <- addr: 0x1b reg: 0x05 val: 0x4000
    mdio-gpio mdio-gpio.0: -> addr: 0x1b reg: 0x07 val: 0x3113
    mdio-gpio mdio-gpio.0: -> addr: 0x1b reg: 0x08 val: 0x0330
    mdio-gpio mdio-gpio.0: -> addr: 0x1b reg: 0x09 val: 0x0000

This is convenient to dynamically debug operations through debugfs with:

    echo file mv88e6xxx.c +p > <debugfs>/dynamic_debug/control

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index cd6807c..3e7e31a 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -85,6 +85,12 @@ int mv88e6xxx_reg_read(struct dsa_switch *ds, int addr, int reg)
 	ret = __mv88e6xxx_reg_read(bus, ds->pd->sw_addr, addr, reg);
 	mutex_unlock(&ps->smi_mutex);
 
+	if (ret < 0)
+		return ret;
+
+	dev_dbg(ds->master_dev, "<- addr: 0x%.2x reg: 0x%.2x val: 0x%.4x\n",
+		addr, reg, ret);
+
 	return ret;
 }
 
@@ -128,6 +134,9 @@ int mv88e6xxx_reg_write(struct dsa_switch *ds, int addr, int reg, u16 val)
 	if (bus == NULL)
 		return -EINVAL;
 
+	dev_dbg(ds->master_dev, "-> addr: 0x%.2x reg: 0x%.2x val: 0x%.4x\n",
+		addr, reg, val);
+
 	mutex_lock(&ps->smi_mutex);
 	ret = __mv88e6xxx_reg_write(bus, ds->pd->sw_addr, addr, reg, val);
 	mutex_unlock(&ps->smi_mutex);
-- 
2.2.2
