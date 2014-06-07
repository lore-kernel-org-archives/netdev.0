From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] net: wimax: i2400m: control.c:  Cleaning up conjunction always evaluates to false
Date: Sat,  7 Jun 2014 13:26:37 +0200
Message-ID: <1402140397-17404-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>,
	linux-wimax@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Logical conjunction always evaluates to false:  minor < 2 && minor > 1
I guess what you wanted is rather: minor > 2 || minor < 1

This was partly found using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 drivers/net/wimax/i2400m/control.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wimax/i2400m/control.c b/drivers/net/wimax/i2400m/control.c
index 4a01e5c..4c41790 100644
--- a/drivers/net/wimax/i2400m/control.c
+++ b/drivers/net/wimax/i2400m/control.c
@@ -1061,7 +1061,7 @@ int i2400m_firmware_check(struct i2400m *i2400m)
 		goto error_bad_major;
 	}
 	result = 0;
-	if (minor < I2400M_HDIv_MINOR_2 && minor > I2400M_HDIv_MINOR)
+	if (minor > I2400M_HDIv_MINOR_2 || minor < I2400M_HDIv_MINOR)
 		dev_warn(dev, "untested minor fw version %u.%u.%u\n",
 			 major, minor, branch);
 	/* Yes, we ignore the branch -- we don't have to track it */
-- 
1.7.10.4
