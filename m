From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [RFC] ethtool: Display reg dump length via get driver info.
Date: Fri, 18 Mar 2011 16:06:23 -0500
Message-ID: <ae232d9a-90c7-47ae-856d-bc5a2b3a8037@exht1.ad.emulex.com>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <bhutchings@solarflare.com>, <ajit.khaparde@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:16150 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757444Ab1CRVHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 17:07:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Devices like BE store Reg Dump Data in the hardware.
This change will allow to just peek into the hardware
to see if any data is available for a dump and analysis,
without actually dumping the register data.

Patch:
----

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 ethtool.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index e9cb2c9..a0c7c99 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1423,11 +1423,13 @@ static int dump_drvinfo(struct ethtool_drvinfo *info)
 		"driver: %s\n"
 		"version: %s\n"
 		"firmware-version: %s\n"
-		"bus-info: %s\n",
+		"bus-info: %s\n"
+		"regdump-len: %d\n",
 		info->driver,
 		info->version,
 		info->fw_version,
-		info->bus_info);
+		info->bus_info,
+		info->regdump_len);
 
 	return 0;
 }
-- 
1.7.1

