From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: bnx2x: Added EEE support
Date: Fri, 8 Jun 2012 16:09:21 +0300
Message-ID: <20120608130921.GA19268@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:25212 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751729Ab2FHNJc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 09:09:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Yuval Mintz,

The patch c8c60d88c59c: "bnx2x: Added EEE support" from Jun 6, 2012, 
leads to the following warning:
drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c:10121 
bnx2x_848x3_config_init()
	 error: buffer overflow 'params->req_duplex' 2 <= 4

drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
 10032          actual_phy_selection = bnx2x_phy_selection(params);
 10033  
 10034          switch (actual_phy_selection) {
 10035          case PORT_HW_CFG_PHY_SELECTION_HARDWARE_DEFAULT:
 10036                  /* Do nothing. Essentially this is like the priority copper */
 10037                  break;
 10038          case PORT_HW_CFG_PHY_SELECTION_FIRST_PHY_PRIORITY:
 10039                  val |= MDIO_CTL_REG_84823_MEDIA_PRIORITY_COPPER;
 10040                  break;
 10041          case PORT_HW_CFG_PHY_SELECTION_SECOND_PHY_PRIORITY:
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
We assume "actual_phy_selection" can be 4 here.

 10042                  val |= MDIO_CTL_REG_84823_MEDIA_PRIORITY_FIBER;
 10043                  break;

[snip]

 10121                  if ((params->req_duplex[actual_phy_selection] == DUPLEX_FULL) &&
                             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
This array only has 2 elements so 4 is beyond the end.

 10122                      (params->eee_mode & EEE_MODE_ADV_LPI) &&
 10123                      (bnx2x_eee_calc_timer(params) ||
 10124                       !(params->eee_mode & EEE_MODE_ENABLE_LPI)))
 10125                          rc = bnx2x_8483x_enable_eee(phy, params, vars);
 10126                  else

regards,
dan carpenter
