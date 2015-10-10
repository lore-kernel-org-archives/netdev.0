From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net-next] bnxt_en: New Broadcom ethernet driver.
Date: Sat, 10 Oct 2015 20:23:02 +0800
Message-ID: <201510102036.G4qCrX3S%fengguang.wu@intel.com>
References: <1444477151-2225-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, davem@davemloft.net, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:41715 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751055AbbJJMYD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Oct 2015 08:24:03 -0400
Content-Disposition: inline
In-Reply-To: <1444477151-2225-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michael,

[auto build test WARNING on net-next/master -- if it's inappropriate base, please ignore]

reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> drivers/net/ethernet/broadcom/bnxt/bnxt.c:3312:30: sparse: incorrect type in assignment (different base types)
   drivers/net/ethernet/broadcom/bnxt/bnxt.c:3312:30:    expected restricted __le16 [addressable] [assigned] [usertype] queue_id
   drivers/net/ethernet/broadcom/bnxt/bnxt.c:3312:30:    got unsigned char [unsigned] [usertype] queue_id

vim +3312 drivers/net/ethernet/broadcom/bnxt/bnxt.c

  3296			req.page_tbl_depth = 1;
  3297		} else {
  3298			req.page_tbl_addr =  cpu_to_le64(ring->dma_arr[0]);
  3299		}
  3300		req.fbo = 0;
  3301		/* Association of ring index with doorbell index and MSIX number */
  3302		req.logical_id = cpu_to_le16(map_index);
  3303	
  3304		switch (ring_type) {
  3305		case HWRM_RING_ALLOC_TX:
  3306			req.ring_type = RING_ALLOC_REQ_RING_TYPE_TX;
  3307			/* Association of transmit ring with completion ring */
  3308			req.cmpl_ring_id =
  3309				cpu_to_le16(bp->grp_info[map_index].cp_fw_ring_id);
  3310			req.length = cpu_to_le32(bp->tx_ring_mask + 1);
  3311			req.stat_ctx_id = cpu_to_le32(stats_ctx_id);
> 3312			req.queue_id = ring->queue_id;
  3313			break;
  3314		case HWRM_RING_ALLOC_RX:
  3315			req.ring_type = RING_ALLOC_REQ_RING_TYPE_RX;
  3316			req.length = cpu_to_le32(bp->rx_ring_mask + 1);
  3317			break;
  3318		case HWRM_RING_ALLOC_AGG:
  3319			req.ring_type = RING_ALLOC_REQ_RING_TYPE_RX;
  3320			req.length = cpu_to_le32(bp->rx_agg_ring_mask + 1);

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
