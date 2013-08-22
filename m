From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] Revert "genetlink: fix family dump race"
Date: Thu, 22 Aug 2013 13:26:31 -0700 (PDT)
Message-ID: <20130822.132631.2273195424430844661.davem@davemloft.net>
References: <1377094083-8122-1-git-send-email-johannes@sipsolutions.net>
	<1377094083-8122-2-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch, johannes.berg@intel.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52291 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754383Ab3HVU0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 16:26:32 -0400
In-Reply-To: <1377094083-8122-2-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Wed, 21 Aug 2013 16:08:02 +0200

> From: Johannes Berg <johannes.berg@intel.com>
> 
> This reverts commit 58ad436fcf49810aa006016107f494c9ac9013db.
> 
> It turns out that the change introduced a potential deadlock
> by causing a locking dependency with netlink's cb_mutex. I
> can't seem to find a way to resolve this without doing major
> changes to the locking, so revert this.
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

So I've applied this since everyone agrees that we should revert
this change.

How to deal with the problem we were attempting to solve is still
under discussion.  It seems that even if we go to RCU we must also
address to module reference count issue.

I think the existing locking is very messy, and RCU looks a lot
cleaner and has potential for future improvements to the scalability
of dumps.

So I'd like to propose that we combine Johannes's RCU conversion
with some variant of the module reference count fix.

Can you guys work together and come up with something I can apply?

Thanks.
