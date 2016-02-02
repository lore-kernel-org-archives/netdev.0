From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 7/7] net: ixgbe: add support for tc_u32 offload
Date: Mon, 01 Feb 2016 18:17:15 -0800 (PST)
Message-ID: <20160201.181715.1355993690912736292.davem@davemloft.net>
References: <20160201014555.13871.56591.stgit@john-Precision-Tower-5810>
	<20160201015310.13871.63596.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anjali.singhai@intel.com, jesse.brandeburg@intel.com,
	jhs@mojatatu.com, ast@fb.com, donald.c.skidmore@intel.com,
	horms@verge.net.au, netdev@vger.kernel.org, tgraf@suug.ch
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45207 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751017AbcBBCRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 21:17:19 -0500
In-Reply-To: <20160201015310.13871.63596.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Sun, 31 Jan 2016 17:53:10 -0800

> +			ixgbe_jump_tables[uhtid] = nexthdr->jump;

I can't figure out what protects concurrent accesses to this shared
ixgbe_jump_table[].  Is RTNL held here?  If so it's likely that
GFP_ATOMIC can be changed to GFP_KERNEL in this function.
