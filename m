From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] bridge: fix bridge netlink RCU usage
Date: Wed, 04 Mar 2015 00:20:44 -0500 (EST)
Message-ID: <20150304.002044.1989204876340561150.davem@davemloft.net>
References: <1425394936-11595-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	stephen@networkplumber.org, johannes.berg@intel.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40671 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752743AbbCDFUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 00:20:46 -0500
In-Reply-To: <1425394936-11595-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Tue,  3 Mar 2015 16:02:16 +0100

> From: Johannes Berg <johannes.berg@intel.com>
> 
> When the STP timer fires, it can call br_ifinfo_notify(),
> which in turn ends up in the new br_get_link_af_size().
> This function is annotated to be using RTNL locking, which
> clearly isn't the case here, and thus lockdep warns:
> 
>   ===============================
>   [ INFO: suspicious RCU usage. ]
>   3.19.0+ #569 Not tainted
>   -------------------------------
>   net/bridge/br_private.h:204 suspicious rcu_dereference_protected() usage!
> 
> Fix this by doing RCU locking here.
> 
> Fixes: b7853d73e39b ("bridge: add vlan info to bridge setlink and dellink notification messages")
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Applied to net-next, thanks Johannes.
