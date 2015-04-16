From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH] dsa: mv88e6xxx: Fix error handling in mv88e6xxx_set_port_state
Date: Wed, 15 Apr 2015 22:12:42 -0700
Message-ID: <1429161162-2028-1-git-send-email-linux@roeck-us.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Return correct error code if _mv88e6xxx_reg_read returns an error.

Fixes: facd95b2e0ec0 ("net: dsa: mv88e6xxx: Add Hardware bridging support")
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6xxx.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index fc8d3b6ffe8e..f64186a5f634 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -908,8 +908,10 @@ static int mv88e6xxx_set_port_state(struct dsa_switch *ds, int port, u8 state)
 	mutex_lock(&ps->smi_mutex);
 
 	reg = _mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_CONTROL);
-	if (reg < 0)
+	if (reg < 0) {
+		ret = reg;
 		goto abort;
+	}
 
 	oldstate = reg & PORT_CONTROL_STATE_MASK;
 	if (oldstate != state) {
-- 
2.1.0
