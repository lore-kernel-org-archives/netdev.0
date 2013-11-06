From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: sch_red: Fix race between timer and
 red_destroy()
Date: Tue, 05 Nov 2013 22:16:33 -0500 (EST)
Message-ID: <20131105.221633.636594084725891709.davem@davemloft.net>
References: <1383617296-20273-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	eric.dumazet@gmail.com
To: subramanian.vijay@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36347 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751050Ab3KFDQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 22:16:34 -0500
In-Reply-To: <1383617296-20273-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vijay Subramanian <subramanian.vijay@gmail.com>
Date: Mon,  4 Nov 2013 18:08:16 -0800

> Make sure timer does not fire once qdisc is destroyed.
> 
> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>

I do not understand how this problem can trigger.

del_timer_sync() waits for all instances of the timer handler which
are running to complete, and then it deletes the timer from any of
the scheduled timer lists.

Your patch is making the mod_timer() in the timer handler conditional,
and this really shouldn't be necessary.

The whole point of del_timer_sync() is to address these kinds of
situations.
