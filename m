From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 patch 1/2][NETNS] fix device renaming for sysfs
Date: Fri, 02 May 2008 17:01:07 -0700 (PDT)
Message-ID: <20080502.170107.107573888.davem@davemloft.net>
References: <20080430213113.410541118@localhost.localdomain>
	<20080430213320.825349005@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60393
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S935584AbYECABI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 20:01:08 -0400
In-Reply-To: <20080430213320.825349005@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Wed, 30 Apr 2008 23:31:14 +0200

> When a netdev is moved across namespaces with the 'dev_change_net_namespace' 
> function, the 'device_rename' function is used to fixup kobject and refresh 
> the sysfs tree. The device_rename function will call kobject_rename and this
> one will check if there is an object with the same name and this is the case
> because we are renaming the object with the same name.
> 
> The use of 'device_rename' seems for me wrong because we usually don't
> rename it but just move it across namespaces. As we just want to do a 
> mini "netdev_[un]register", IMO the functions 'netdev_[un]register_kobject' 
> should be used instead, like an usual network device [un]registering.
> 
> This patch replace device_rename by netdev_unregister_kobject, followed by
> netdev_register_kobject.
> 
> The netdev_register_kobject will call device_initialize and will raise a 
> warning indicating the device was already initialized. In order to fix that,
> I split the device initialization into a separate function and use it together
> with 'netdev_register_kobject' into register_netdevice. So we can safely call
> 'netdev_register_kobject' in 'dev_change_net_namespace'.
> 
> This fix will allow to properly use the sysfs per namespace which is coming
> from -mm tree.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
> Acked-by: Benjamin Thery <benjamin.thery@bull.net>

Looks good, applied.
