From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6: fix ecmp lookup when oif is specified
Date: Sun, 23 Jun 2013 18:40:18 -0700 (PDT)
Message-ID: <20130623.184018.934611809597741522.davem@davemloft.net>
References: <20130613.173829.683328203745717078.davem@davemloft.net>
	<1371198778-26099-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35011 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752040Ab3FXBkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jun 2013 21:40:19 -0400
In-Reply-To: <1371198778-26099-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 14 Jun 2013 10:32:58 +0200

> There is no reason to skip ECMP lookup when oif is specified, but this implies
> to check oif given by user when selecting another route.
> When the new route does not match oif requirement, we simply keep the initial
> one.
> 
> Spotted-by: dingzhi <zhi.ding@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

IPV4 routing has elided the multipath lookup when the interface is specified
for nearly two decades.

So two things:

1) A decision that old must have a good reason, and you must do some
   research to figure out exactly what that reason is.

2) If ipv4 is found to be wrong too, we must bring both ipv4 and ipv6
   into the same behavior at the same time.

But I do not want to make this change for another reason, it potentially
breaks things for someone, somewhere.  And I see very miniscule, if any,
value to this new behavior.  The risk far outweighs the gains.

Sorry, I really have to reject this patch for now.
