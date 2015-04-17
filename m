From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: [PATCH v1 net-next 2/2] igb: support SIOCSMIIREG
Date: Fri, 17 Apr 2015 13:24:00 -0700
Message-ID: <1429302240-654-2-git-send-email-jtoppins@cumulusnetworks.com>
References: <1429302240-654-1-git-send-email-jtoppins@cumulusnetworks.com>
Cc: jesse.brandeburg@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, gospo@cumulusnetworks.com,
	shm@cumulusnetworks.com, Alan Liebthal <alanl@cumulusnetworks.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34265 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751768AbbDQUYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2015 16:24:17 -0400
Received: by pacyx8 with SMTP id yx8so135837873pac.1
        for <netdev@vger.kernel.org>; Fri, 17 Apr 2015 13:24:16 -0700 (PDT)
In-Reply-To: <1429302240-654-1-git-send-email-jtoppins@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Liebthal <alanl@cumulusnetworks.com>

Support setting the MII register via SIOCSMIIREG.

Signed-off-by: Alan Liebthal <alanl@cumulusnetworks.com>
Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 720b785..1071a71 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -7141,6 +7141,11 @@ static int igb_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 			return -EIO;
 		break;
 	case SIOCSMIIREG:
+		adapter->hw.phy.addr = data->phy_id;
+		if (igb_write_phy_reg(&adapter->hw, data->reg_num & 0x1F,
+				      data->val_in))
+			return -EIO;
+		break;
 	default:
 		return -EOPNOTSUPP;
 	}
-- 
1.7.10.4
