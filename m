From: kbuild test robot <lkp@intel.com>
Subject: Re: [RFC v3 net-next 07/10] qed: Add link support
Date: Wed, 30 Sep 2015 22:08:40 +0800
Message-ID: <201509302215.QZctJocl%fengguang.wu@intel.com>
References: <1443618217-18069-8-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org, Ariel.Elior@qlogic.com,
	Yuval.Mintz@qlogic.com
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:56351 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753610AbbI3OJb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 10:09:31 -0400
Content-Disposition: inline
In-Reply-To: <1443618217-18069-8-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Yuval,

[auto build test results on v4.3-rc3 -- if it's inappropriate base, please ignore]

reproduce:
  # apt-get install sparse
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> drivers/net/ethernet/qlogic/qed/qed_int.c:181:29: sparse: incorrect type in assignment (different base types)
   drivers/net/ethernet/qlogic/qed/qed_int.c:181:29:    expected restricted __le16 [usertype] sb_index
   drivers/net/ethernet/qlogic/qed/qed_int.c:181:29:    got unsigned short [unsigned] [assigned] [usertype] index
   include/linux/qed/qed_if.h:430:16: sparse: restricted __le32 degrades to integer
   include/linux/qed/qed_if.h:430:16: sparse: cast to restricted __le32
--
   drivers/net/ethernet/qlogic/qed/qed_mcp.c:87:21: sparse: incorrect type in assignment (different base types)
   drivers/net/ethernet/qlogic/qed/qed_mcp.c:87:21:    expected restricted __be32 [usertype] tmp
   drivers/net/ethernet/qlogic/qed/qed_mcp.c:87:21:    got unsigned int
>> drivers/net/ethernet/qlogic/qed/qed_mcp.c:622:55: sparse: incorrect type in argument 4 (different base types)
   drivers/net/ethernet/qlogic/qed/qed_mcp.c:622:55:    expected unsigned int [unsigned] [usertype] val
   drivers/net/ethernet/qlogic/qed/qed_mcp.c:622:55:    got restricted __be32 [usertype] val

vim +181 drivers/net/ethernet/qlogic/qed/qed_int.c

   165	{
   166		struct qed_sb_attn_info	 *p_sb_attn_sw   = p_hwfn->p_sb_attn;
   167		struct atten_status_block       *p_sb_attn      = p_sb_attn_sw->sb_attn;
   168		u32			     attn_bits       = 0, attn_acks = 0;
   169		u16			     index	   = 0, asserted_bits,
   170						deasserted_bits;
   171		int			     rc = 0;
   172	
   173		/* Read current attention bits/acks - safeguard against attentions
   174		 * by guaranting work on a synchronized timeframe
   175		 */
   176		do {
   177			index	   = le16_to_cpu(p_sb_attn->sb_index);
   178			attn_bits       = le32_to_cpu(p_sb_attn->atten_bits);
   179			attn_acks       = le32_to_cpu(p_sb_attn->atten_ack);
   180		} while (index != le16_to_cpu(p_sb_attn->sb_index));
 > 181		p_sb_attn->sb_index = index;
   182	
   183		/* Attention / Deassertion are meaningful (and in correct state)
   184		 * only when they differ and consistent with known state - deassertion
   185		 * when previous attention & current ack, and assertion when current
   186		 * attention with no previous attention
   187		 */
   188		asserted_bits = (attn_bits & ~attn_acks & ATTN_STATE_BITS) &
   189			~p_sb_attn_sw->known_attn;

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
