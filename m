From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: mlx4_core: Modify driver initialization flow to accommodate
 SRIOV for Ethernet
Date: Sat, 9 Jun 2012 12:09:18 +0300
Message-ID: <20120609090918.GB877@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jackm@dev.mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:44856 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751045Ab2FIJJ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2012 05:09:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Jack Morgenstein,

The patch ab9c17a009ee: "mlx4_core: Modify driver initialization flow 
to accommodate SRIOV for Ethernet" from Dec 13, 2011, leads to the 
following static checker warning:

drivers/net/ethernet/mellanox/mlx4/main.c:424 mlx4_slave_cap()
	warn: suspicious bitop condition

   423          /*fail if the hca has an unknown capability */
   424          if ((hca_param.global_caps | HCA_GLOBAL_CAP_MASK) !=
   425              HCA_GLOBAL_CAP_MASK) {
   426                  mlx4_err(dev, "Unknown hca global capabilities\n");
   427                  return -ENOSYS;
   428          }

The test sort of makes sense but HCA_GLOBAL_CAP_MASK is zero so we could
as well say:

	if (hca_param.global_caps) { ...

regards,
dan carpenter
