From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 4/7] net: dsa: mv88e6xxx: flush ATU on initial setup
Date: Fri,  4 Sep 2015 14:34:13 -0400
Message-ID: <1441391656-22574-5-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1441391656-22574-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip-208-88-110-44.savoirfairelinux.net ([208.88.110.44]:57179
	"EHLO mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753601AbbIDSfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2015 14:35:08 -0400
In-Reply-To: <1441391656-22574-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Purge all MAC addresses from the entire set of address databases when
the driver initializes the device.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index c67090f..38c8d4a 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2685,6 +2685,11 @@ int mv88e6xxx_setup_global(struct dsa_switch *ds)
 	if (ret < 0)
 		goto unlock;
 
+	/* Clear all ATU entries */
+	ret = _mv88e6xxx_atu_flush(ds, 0, true);
+	if (ret < 0)
+		goto unlock;
+
 	/* Clear all the VTU and STU entries */
 	ret = _mv88e6xxx_vtu_stu_flush(ds);
 unlock:
-- 
2.5.1
