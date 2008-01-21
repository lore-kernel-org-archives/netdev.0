From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: rtnl_link: fix use-after-free
Date: Sun, 20 Jan 2008 17:25:24 -0800 (PST)
Message-ID: <20080120.172524.230298873.davem@davemloft.net>
References: <47938317.1070906@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42708
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756403AbYAUBZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 20:25:19 -0500
In-Reply-To: <47938317.1070906@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Sun, 20 Jan 2008 18:21:27 +0100

> commit 6e470bd53fb50632fe1878bb74bb8531a21b6731
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Sun Jan 20 18:19:15 2008 +0100
> 
>     [NET]: rtnl_link: fix use-after-free
>     
>     When unregistering the rtnl_link_ops, all existing devices using
>     the ops are destroyed. With nested devices this may lead to a
>     use-after-free despite the use of for_each_netdev_safe() in case
>     the upper device is next in the device list and is destroyed
>     by the NETDEV_UNREGISTER notifier.
>     
>     The easy fix is to restart scanning the device list after removing
>     a device. Alternatively we could add new devices to the front of
>     the list to avoid having dependant devices follow the device they
>     depend on. A third option would be to only restart scanning if
>     dev->iflink of the next device matches dev->ifindex of the current
>     one. For now this seems like the safest solution.
>     
>     With this patch, the veth rtnl_link_ops unregistration can use
>     rtnl_link_unregister() directly since it now also handles destruction
>     of multiple devices at once.
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks.
