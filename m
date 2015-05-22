From: Arun Parameswaran <aparames@broadcom.com>
Subject: [PATCH 2/2] ethtool: Fix an issue with handling 'phyad' while updating settings
Date: Fri, 22 May 2015 15:43:29 -0700
Message-ID: <1432334609-3971-3-git-send-email-aparames@broadcom.com>
References: <1432334609-3971-1-git-send-email-aparames@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <jdzheng@broadcom.com>,
	<aparames@broadcom.com>
To: Ben Hutchings <bwh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:58230 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756929AbbEVWng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 18:43:36 -0400
In-Reply-To: <1432334609-3971-1-git-send-email-aparames@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using the 'ethtool' to set PHY1's settings, the 'ethtool'
seems to do the 'get' settings with incorrect PHY ID and then
apply the new settings on it.

For example when using the command, to change PHY1's speed,
'ethtool -s eth0 phyad 1 speed 100', the 'ethtool' will end up
querying PHY0's settings and then apply the new settings specified
in the command on top of the PHY0's settings. So the PHY1 will
end up with worng settings (partial settings of PHY0 for example).

This patch fixes the issue by specifying the 'phyad' or 'port'
requested in the command to query for the settings, before applying
the new ones.

Signed-off-by: Arun Parameswaran <aparames@broadcom.com>
Reviewed-by: JD (Jiandong) Zheng <jdzheng@broadcom.com>
---
 ethtool.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/ethtool.c b/ethtool.c
index 668c189..6c57297 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -2523,6 +2523,12 @@ static int do_sset(struct cmd_context *ctx)
 
 		memset(&ecmd, 0, sizeof(struct ethtool_cmd));
 
+		if (phyad_wanted != -1)
+			ecmd.phy_address = phyad_wanted;
+
+		if (port_wanted != -1)
+			ecmd.port = port_wanted;
+
 		ecmd.cmd = ETHTOOL_GSET;
 		err = send_ioctl(ctx, &ecmd);
 		if (err < 0) {
-- 
1.7.9.5
