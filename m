From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 1/6] MIPS: Octeon: Add platform device for MDIO buses.
Date: Wed,  7 Oct 2009 16:10:10 -0700
Message-ID: <1254957015-7633-1-git-send-email-ddaney@caviumnetworks.com>
References: <4ACD1F4E.8090603@caviumnetworks.com>
Cc: David Daney <ddaney@caviumnetworks.com>
To: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <4ACD1F4E.8090603@caviumnetworks.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

Signed-off-by: David Daney <ddaney@caviumnetworks.com>
---
 arch/mips/cavium-octeon/octeon-platform.c |   30 +++++++++++++++++++++++++++++
 1 files changed, 30 insertions(+), 0 deletions(-)

diff --git a/arch/mips/cavium-octeon/octeon-platform.c b/arch/mips/cavium-octeon/octeon-platform.c
index be711dd..febfdd7 100644
--- a/arch/mips/cavium-octeon/octeon-platform.c
+++ b/arch/mips/cavium-octeon/octeon-platform.c
@@ -159,6 +159,36 @@ out:
 }
 device_initcall(octeon_rng_device_init);
 
+/* Octeon SMI/MDIO interface.  */
+static int __init octeon_mdiobus_device_init(void)
+{
+	struct platform_device *pd;
+	int ret = 0;
+
+	if (octeon_is_simulation())
+		return 0; /* No mdio in the simulator. */
+
+	/* The bus number is the platform_device id.  */
+	pd = platform_device_alloc("mdio-octeon", 0);
+	if (!pd) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	ret = platform_device_add(pd);
+	if (ret)
+		goto fail;
+
+	return ret;
+fail:
+	platform_device_put(pd);
+
+out:
+	return ret;
+
+}
+device_initcall(octeon_mdiobus_device_init);
+
 MODULE_AUTHOR("David Daney <ddaney@caviumnetworks.com>");
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("Platform driver for Octeon SOC");
-- 
1.6.0.6
