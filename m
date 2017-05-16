From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: fix PF falsely indicating success at
 setting MAC address of a nonexistent VF
Date: Tue, 16 May 2017 11:28:00 -0700
Message-ID: <20170516182800.GA1067@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0051.outbound.protection.outlook.com ([104.47.42.51]:40342
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750853AbdEPS2G (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 16 May 2017 14:28:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the function assigned to .ndo_set_vf_mac, check the validity of the
vfidx argument before proceeding to tell the firmware to set the VF MAC
address.

Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 927617c..eed6ff0 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -3694,6 +3694,9 @@ static int liquidio_set_vf_mac(struct net_device *netdev, int vfidx, u8 *mac)
 	struct octeon_device *oct = lio->oct_dev;
 	int retval;
 
+	if (vfidx < 0 || vfidx >= oct->sriov_info.num_vfs_alloced)
+		return -EINVAL;
+
 	retval = __liquidio_set_vf_mac(netdev, vfidx, mac, true);
 	if (!retval)
 		cn23xx_tell_vf_its_macaddr_changed(oct, vfidx, mac);
