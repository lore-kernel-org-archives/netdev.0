From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: fix gc_timer mod/del race condition
Date: Tue, 13 Oct 2015 04:52:16 -0700 (PDT)
Message-ID: <20151013.045216.838190689363270571.davem@davemloft.net>
References: <1444665355-28448-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, sfeldma@gmail.com,
	roopa@cumulusnetworks.com, stephen@networkplumber.org,
	bridge@lists.linux-foundation.org, nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47577 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932324AbbJMLgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 07:36:17 -0400
In-Reply-To: <1444665355-28448-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Mon, 12 Oct 2015 17:55:55 +0200

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> commit c62987bbd8a1 ("bridge: push bridge setting ageing_time down to
> switchdev") introduced a timer race condition because the gc_timer can
> get rearmed after it's supposedly stopped and flushed in br_dev_delete()
> leading to a use of freed memory. So take rtnl to sync with bridge
> destruction when setting ageing_timer.
> Here's the trace reproduced with these two commands running in parallel:
> while :; do echo 10000 > /sys/class/net/br0/bridge/ageing_timer; done;
> while :; do brctl addbr br0; ip l set br0 up; ip l set br0 down;
> brctl delbr br0; done;
 ...
> Fixes: c62987bbd8a1 ("bridge: push bridge setting ageing_time down to switchdev")
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied, thanks.
