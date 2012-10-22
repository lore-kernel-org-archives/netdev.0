From: Yuanhan Liu <yuanhan.liu@intel.com>
Subject: [net-next:master 28/31]
 drivers/net/ethernet/emulex/benet/be_main.c:3116 be_flash() error:
 __builtin_memcpy() 'req->params.data_buf' too small (4 vs 32768)
Date: Mon, 22 Oct 2012 11:20:27 +0800
Message-ID: <20121022032027.GA14218@yliu-dev.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yuanhan Liu <yuanhan.liu@intel.com>, fengguang.wu@intel.com,
	Vasundhara Volam <vasundhara.volam@emulex.com>,
	netdev@vger.kernel.org
To: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35603 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932808Ab2JVDUU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Oct 2012 23:20:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Padmanabh,

FYI, there are new smatch warnings show up in

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   46baac38ef633b08168d27df7b02eb14578fb760
commit: 773a2d7c55a3d63207841c824d21920bd3683460 [28/31] be2net: Fix FW flashing on Skyhawk-R

+ drivers/net/ethernet/emulex/benet/be_main.c:3116 be_flash() error: __builtin_memcpy() 'req->params.data_buf' too small (4 vs 32768)

vim +3116 drivers/net/ethernet/emulex/benet/be_main.c

773a2d7c Padmanabh Ratnakar 2012-10-20  3100  		num_bytes = min_t(u32, 32*1024, total_bytes);
773a2d7c Padmanabh Ratnakar 2012-10-20  3101  
773a2d7c Padmanabh Ratnakar 2012-10-20  3102  		total_bytes -= num_bytes;
773a2d7c Padmanabh Ratnakar 2012-10-20  3103  
773a2d7c Padmanabh Ratnakar 2012-10-20  3104  		if (!total_bytes) {
773a2d7c Padmanabh Ratnakar 2012-10-20  3105  			if (optype == OPTYPE_PHY_FW)
773a2d7c Padmanabh Ratnakar 2012-10-20  3106  				flash_op = FLASHROM_OPER_PHY_FLASH;
773a2d7c Padmanabh Ratnakar 2012-10-20  3107  			else
773a2d7c Padmanabh Ratnakar 2012-10-20  3108  				flash_op = FLASHROM_OPER_FLASH;
773a2d7c Padmanabh Ratnakar 2012-10-20  3109  		} else {
773a2d7c Padmanabh Ratnakar 2012-10-20  3110  			if (optype == OPTYPE_PHY_FW)
773a2d7c Padmanabh Ratnakar 2012-10-20  3111  				flash_op = FLASHROM_OPER_PHY_SAVE;
773a2d7c Padmanabh Ratnakar 2012-10-20  3112  			else
773a2d7c Padmanabh Ratnakar 2012-10-20  3113  				flash_op = FLASHROM_OPER_SAVE;
773a2d7c Padmanabh Ratnakar 2012-10-20  3114  		}
773a2d7c Padmanabh Ratnakar 2012-10-20  3115  
773a2d7c Padmanabh Ratnakar 2012-10-20 @3116  		memcpy(req->params.data_buf, img, num_bytes);
773a2d7c Padmanabh Ratnakar 2012-10-20  3117  		img += num_bytes;
773a2d7c Padmanabh Ratnakar 2012-10-20  3118  		status = be_cmd_write_flashrom(adapter, flash_cmd, optype,
773a2d7c Padmanabh Ratnakar 2012-10-20  3119  						flash_op, num_bytes);
773a2d7c Padmanabh Ratnakar 2012-10-20  3120  		if (status) {
773a2d7c Padmanabh Ratnakar 2012-10-20  3121  			if (status == ILLEGAL_IOCTL_REQ &&
773a2d7c Padmanabh Ratnakar 2012-10-20  3122  			    optype == OPTYPE_PHY_FW)
773a2d7c Padmanabh Ratnakar 2012-10-20  3123  				break;
773a2d7c Padmanabh Ratnakar 2012-10-20  3124  			dev_err(&adapter->pdev->dev,

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation
