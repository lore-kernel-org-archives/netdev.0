From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: fix netlink_ack() extack race
Date: Wed, 18 Oct 2017 12:23:31 +0100 (WEST)
Message-ID: <20171018.122331.1844401861159598600.davem@davemloft.net>
References: <20171016150953.17612-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        johannes.berg@intel.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59830 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753016AbdJRLXh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 07:23:37 -0400
In-Reply-To: <20171016150953.17612-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Mon, 16 Oct 2017 17:09:53 +0200

> From: Johannes Berg <johannes.berg@intel.com>
> 
> It seems that it's possible to toggle NETLINK_F_EXT_ACK
> through setsockopt() while another thread/CPU is building
> a message inside netlink_ack(), which could then trigger
> the WARN_ON()s I added since if it goes from being turned
> off to being turned on between allocating and filling the
> message, the skb could end up being too small.
> 
> Avoid this whole situation by storing the value of this
> flag in a separate variable and using that throughout the
> function instead.
> 
> Fixes: 2d4bc93368f5 ("netlink: extended ACK reporting")
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Applied and queued up for -stable.
