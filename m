From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: make nlmsg_end() and genlmsg_end() void
Date: Sun, 18 Jan 2015 01:04:46 -0500 (EST)
Message-ID: <20150118.010446.405197490184285420.davem@davemloft.net>
References: <1421442540-10244-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes.berg@intel.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42519 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750757AbbARGEu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 01:04:50 -0500
In-Reply-To: <1421442540-10244-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Fri, 16 Jan 2015 22:09:00 +0100

 ...
> Remove this, and make the functions void. This removes a bunch of dead
> code as described above. The patch adds lines because I did
> 
> -	return nlmsg_end(...);
> +	nlmsg_end(...);
> +	return 0;
> 
> I could have preserved all the function's return values by returning
> skb->len, but instead I've audited all the places calling the affected
> functions and found that none cared. A few places actually compared
> the return value with <= 0 in dump functionality, but that could just
> be changed to < 0 with no change in behaviour, so I opted for the more
> efficient version.
> 
> One instance of the error I've made numerous times now is also present
> in net/phonet/pn_netlink.c in the route_dumpit() function - it didn't
> check for <0 or <=0 and thus broke out of the loop every single time.
> I've preserved this since it will (I think) have caused the messages to
> userspace to be formatted differently with just a single message for
> every SKB returned to userspace. It's possible that this isn't needed
> for the tools that actually use this, but I don't even know what they
> are so couldn't test that changing this behaviour would be acceptable.
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

I like this, applied, thanks Johannes.

You know, I would even be willing to apply a patch adjusting that phonet
case.  So feel free to submit that.
