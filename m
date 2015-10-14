From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net-next v2] bnxt_en: New Broadcom ethernet driver.
Date: Wed, 14 Oct 2015 12:09:37 +0800
Message-ID: <201510141244.6VgZRGZt%fengguang.wu@intel.com>
References: <1444792633-7679-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, davem@davemloft.net, prashant@broadcom.com,
	eddie.wai@broadcom.com, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:30352 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750719AbbJNEKN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2015 00:10:13 -0400
Content-Disposition: inline
In-Reply-To: <1444792633-7679-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michael,

[auto build test WARNING on net-next/master -- if it's inappropriate base, please suggest rules for selecting the more suitable base]

url:    https://github.com/0day-ci/linux/commits/Michael-Chan/bnxt_en-New-Broadcom-ethernet-driver/20151014-112018
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c:204:20: sparse: incorrect type in assignment (different base types)
   drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c:204:20:    expected restricted __le32 [addressable] [assigned] [usertype] max_bw
   drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c:204:20:    got int [signed] max_tx_rate
>> drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c:206:20: sparse: incorrect type in assignment (different base types)
   drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c:206:20:    expected restricted __le32 [addressable] [assigned] [usertype] min_bw
   drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c:206:20:    got int [signed] min_tx_rate

vim +204 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c

   198		if (min_tx_rate == vf->min_tx_rate && max_tx_rate == vf->max_tx_rate)
   199			return 0;
   200		bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_FUNC_CFG, -1, -1);
   201		req.vf_id = cpu_to_le16(vf->fw_fid);
   202		req.flags = cpu_to_le32(vf->func_flags);
   203		req.enables = cpu_to_le32(FUNC_CFG_REQ_ENABLES_MAX_BW);
 > 204		req.max_bw = max_tx_rate;
   205		req.enables |= cpu_to_le32(FUNC_CFG_REQ_ENABLES_MIN_BW);
 > 206		req.min_bw = min_tx_rate;
   207		rc = hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
   208		if (!rc) {
   209			vf->min_tx_rate = min_tx_rate;

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
