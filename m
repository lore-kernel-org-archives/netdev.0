From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] netlink: Trim skb to alloc size to avoid
 MSG_TRUNC
Date: Sun, 18 Oct 2015 19:33:56 -0700 (PDT)
Message-ID: <20151018.193356.1252632768047689966.davem@davemloft.net>
References: <1444698923-13992-1-git-send-email-ronen.arad@intel.com>
	<1444899317-3345-1-git-send-email-ronen.arad@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ronen.arad@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48707 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752114AbbJSCRj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2015 22:17:39 -0400
In-Reply-To: <1444899317-3345-1-git-send-email-ronen.arad@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ronen Arad <ronen.arad@intel.com>
Date: Thu, 15 Oct 2015 01:55:17 -0700

> netlink_dump() allocates skb based on the calculated min_dump_alloc or
> a per socket max_recvmsg_len.
> min_alloc_size is maximum space required for any single netdev
> attributes as calculated by rtnl_calcit().
> max_recvmsg_len tracks the user provided buffer to netlink_recvmsg.
> It is capped at 16KiB.
> The intention is to avoid small allocations and to minimize the number
> of calls required to obtain dump information for all net devices.
> 
> netlink_dump packs as many small messages as could fit within an skb
> that was sized for the largest single netdev information. The actual
> space available within an skb is larger than what is requested. It could
> be much larger and up to near 2x with align to next power of 2 approach.
> 
> Allowing netlink_dump to use all the space available within the
> allocated skb increases the buffer size a user has to provide to avoid
> truncaion (i.e. MSG_TRUNG flag set).
> 
> It was observed that with many VLANs configured on at least one netdev,
> a larger buffer of near 64KiB was necessary to avoid "Message truncated"
> error in "ip link" or "bridge [-c[ompressvlans]] vlan show" when
> min_alloc_size was only little over 32KiB.
> 
> This patch trims skb to allocated size in order to allow the user to
> avoid truncation with more reasonable buffer size.
> 
> Signed-off-by: Ronen Arad <ronen.arad@intel.com>

Getting spurious MSG_TRUNC is surely a bug, so I am going to apply
this to 'net' as it is a genuine bug fix.

Thanks.
