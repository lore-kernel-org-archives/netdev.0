From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net] net: ipmr, ip6mr: fix vif/tunnel failure race
 condition
Date: Tue, 24 Nov 2015 17:16:27 -0500 (EST)
Message-ID: <20151124.171627.1039186928574279469.davem@redhat.com>
References: <1448381370-32173-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53126 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755171AbbKXWQ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2015 17:16:29 -0500
In-Reply-To: <1448381370-32173-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Tue, 24 Nov 2015 17:09:30 +0100

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> Since (at least) commit b17a7c179dd3 ("[NET]: Do sysfs registration as
> part of register_netdevice."), netdev_run_todo() deals only with
> unregistration, so we don't need to do the rtnl_unlock/lock cycle to
> finish registration when failing pimreg or dvmrp device creation. In
> fact that opens a race condition where someone can delete the device
> while rtnl is unlocked because it's fully registered. The problem gets
> worse when netlink support is introduced as there are more points of entry
> that can cause it and it also makes reusing that code correctly impossible.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
> I was able to crash the kernel by artificially triggering this race just to
> confim it. I know it's very unlikely to hit the race in the real world, but
> the biggest advantage of the change is that the code can be re-used later
> when adding netlink support.

Applied, thank you.
