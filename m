From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: LRO num of frags limit
Date: Tue, 16 Sep 2008 10:36:32 +0300
Message-ID: <20080916073632.GA25226@mtls03>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, themann@de.ibm.com,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:34512 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752760AbYIPHf3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2008 03:35:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

looking at the LRO code, at __lro_proc_segment(), it seems that the
network driver can configure lro_mgr->max_aggr to any value it wants
while the number of fragments aggregated must not exceed MAX_SKB_FRAGS
(since we only use a single SKB to aggregate fragments, allocated by
lro_gen_skb()). Moreover, even if the driver does limit
lro_mgr->max_aggr to MAX_SKB_FRAGS, it might still cause overflow
since subsequent aggregations are done at lro_add_frags() which is
called before checking whether we overflow.
If the above observation is correct, I can send a patch.

Thanks,
Eli
