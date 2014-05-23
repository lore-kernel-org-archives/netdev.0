From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] qlcnic: info leak in qlcnic_dcb_peer_app_info()
Date: Fri, 23 May 2014 19:37:21 +0300
Message-ID: <20140523163721.GA14067@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dept-HSGLinuxNICDev@qlogic.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:39914 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753035AbaEWQhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 12:37:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function is called from dcbnl_build_peer_app().  The "info"
struct isn't initialized at all so we disclose 2 bytes of uninitialized
stack data.  We should clear it before passing it to the user.

Fixes: 48365e485275 ('qlcnic: dcb: Add support for CEE Netlink interface.')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
This is a static analysis patch, and I am not familiar with this code.
We may want to put some useful information here, to go with the
app_count.

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
index a51fe18..561cb11 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
@@ -1020,6 +1020,7 @@ static int qlcnic_dcb_peer_app_info(struct net_device *netdev,
 	struct qlcnic_dcb_cee *peer;
 	int i;
 
+	memset(info, 0, sizeof(*info));
 	*app_count = 0;
 
 	if (!test_bit(QLCNIC_DCB_STATE, &adapter->dcb->state))
