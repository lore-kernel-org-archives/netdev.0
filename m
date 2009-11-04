From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/2 13/15] wimax/i2400m: verify firmware format version is known
Date: Wed,  4 Nov 2009 13:39:54 -0800
Message-ID: <fabce1a485dd985c0e4c16f61f4ddb5e27e49cbf.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:20702 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932699AbZKDVmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:00 -0500
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure the bootloading code checks that the format of the file is
understood (major version match). This also fixes a dumb typo in
extracting the major version field.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/fw.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wimax/i2400m/fw.c b/drivers/net/wimax/i2400m/fw.c
index eef236d..1fd2fee 100644
--- a/drivers/net/wimax/i2400m/fw.c
+++ b/drivers/net/wimax/i2400m/fw.c
@@ -1179,7 +1179,7 @@ int i2400m_fw_check(struct i2400m *i2400m,
 
 	module_type = bcf->module_type;
 	header_len = sizeof(u32) * le32_to_cpu(bcf->header_len);
-	major_version = le32_to_cpu(bcf->header_version) & 0xffff0000 >> 16;
+	major_version = (le32_to_cpu(bcf->header_version) & 0xffff0000) >> 16;
 	minor_version = le32_to_cpu(bcf->header_version) & 0x0000ffff;
 	module_id = le32_to_cpu(bcf->module_id);
 	module_vendor = le32_to_cpu(bcf->module_vendor);
@@ -1205,6 +1205,12 @@ int i2400m_fw_check(struct i2400m *i2400m,
 		goto error;
 	}
 
+	if (major_version != 1) {
+		dev_err(dev, "%s: major header version v%u.%u not supported\n",
+			i2400m->fw_name, major_version, minor_version);
+		goto error;
+	}
+
 	/* Check soft-er errors */
 	result = 0;
 	if (module_vendor != 0x8086)
-- 
1.6.2.5

