From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] rtnetlink: call ->dellink on failure when ->newlink
 exists
Date: Sun, 15 Feb 2015 08:31:12 -0800 (PST)
Message-ID: <20150215.083112.1760236558330375715.davem@davemloft.net>
References: <1423864613-29637-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ignacy.gawedzki@green-communications.fr
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45833 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754627AbbBOQYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 11:24:03 -0500
In-Reply-To: <1423864613-29637-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 13 Feb 2015 13:56:53 -0800

> Ignacy reported that when eth0 is down and add a vlan device
> on top of it like:
> 
>   ip link add link eth0 name eth0.1 up type vlan id 1
> 
> We will get a refcount leak:
> 
>   unregister_netdevice: waiting for eth0.1 to become free. Usage count = 2
> 
> The problem is when rtnl_configure_link() fails in rtnl_newlink(),
> we simply call unregister_device(), but for stacked device like vlan,
> we almost do nothing when we unregister the upper device, more work
> is done when we unregister the lower device, so call its ->dellink().
> 
> Reported-by: Ignacy Gawedzki <ignacy.gawedzki@green-communications.fr>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks.
