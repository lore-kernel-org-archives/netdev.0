From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/rds: fix unaligned memory access
Date: Sun, 03 May 2015 23:39:19 -0400 (EDT)
Message-ID: <20150503.233919.1745167313833037648.davem@davemloft.net>
References: <1430441887-37808-1-git-send-email-david.ahern@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	shamir.rabinovitch@oracle.com
To: david.ahern@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59415 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172AbbEDDjV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2015 23:39:21 -0400
In-Reply-To: <1430441887-37808-1-git-send-email-david.ahern@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <david.ahern@oracle.com>
Date: Thu, 30 Apr 2015 20:58:07 -0400

> From: shamir rabinovitch <shamir.rabinovitch@oracle.com>
> 
> rdma_conn_param private data is copied using memcpy after headers such
> as cma_hdr (see cma_resolve_ib_udp as example). so the start of the
> private data is aligned to the end of the structure that come before. if
> this structure end with u32 the meaning is that the start of the private
> data will be 4 bytes aligned. structures that use u8/u16/u32/u64 are
> naturally aligned but in case the structure start is not 8 bytes aligned,
> all u64 members of this structure will not be aligned. to solve this issue
> we must use special macros that allow unaligned access to those
> unaligned members.
> 
> Addresses the following kernel log seen when attempting to use RDMA:
> 
> Kernel unaligned access at TPC[10507a88] rds_ib_cm_connect_complete+0x1bc/0x1e0 [rds_rdma]
> 
> Acked-by: Chien Yen <chien.yen@oracle.com>
> Signed-off-by: shamir rabinovitch <shamir.rabinovitch@oracle.com>
> [Minor tweaks for top of tree by:]
> Signed-off-by: David Ahern <david.ahern@oracle.com>

Applied, thanks.
