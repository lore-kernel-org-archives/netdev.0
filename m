From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bonding: properly stop queuing work when requested
Date: Mon, 03 Oct 2011 13:48:56 -0400 (EDT)
Message-ID: <20111003.134856.2253211244720214327.davem@davemloft.net>
References: <1316811214-15002-1-git-send-email-andy@greyhouse.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56018 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932238Ab1JCRs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 13:48:59 -0400
In-Reply-To: <1316811214-15002-1-git-send-email-andy@greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <andy@greyhouse.net>
Date: Fri, 23 Sep 2011 16:53:34 -0400

> During a test where a pair of bonding interfaces using ARP monitoring
> were both brought up and torn down (with an rmmod) repeatedly, a panic
> in the timer code was noticed.  I tracked this down and determined that
> any of the bonding functions that ran as workqueue handlers and requeued
> more work might not properly exit when the module was removed.
> 
> There was a flag protected by the bond lock called kill_timers that is
> set when the interface goes down or the module is removed, but many of
> the functions that monitor link status now unlock the bond lock to take
> rtnl first.  There is a chance that another CPU running the rmmod could
> get the lock and set kill_timers after the first check has passed.
> 
> This patch does not allow any function to queue work that will make
> itself run unless kill_timers is not set.  I also noticed while doing
> this work that bond_resend_igmp_join_requests did not have a check for
> kill_timers, so I added the needed call there as well.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> Reported-by: Liang Zheng <lzheng@redhat.com>

Applied, thanks Andy.
