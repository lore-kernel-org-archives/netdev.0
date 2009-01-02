From: David Miller <davem@davemloft.net>
Subject: Re: ixgbe select_queue broken in 2.6.28
Date: Fri, 02 Jan 2009 00:19:33 -0800 (PST)
Message-ID: <20090102.001933.70654029.davem@davemloft.net>
References: <20090101225456.68f4fe9d@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, donald.c.skidmore@intel.com,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56512
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751426AbZABITa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2009 03:19:30 -0500
In-Reply-To: <20090101225456.68f4fe9d@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 1 Jan 2009 22:54:56 -0800

> The ixgbe driver in 2.6.28 modifies select_queue. This is bad
> in a couple of ways:
>   1) select_queue is now in net_device_ops so the driver won't build
>      unless CONFIG_COMPAT_NET_DEV_OPS is defined
>   2) it is changing data that is shared and supposed to be immutable.
> 
> Looks like a some of the DCB stuff forgot to look at net_device_ops

Drivers shouldn't be overriding the ->select_queue() method unless
there is a very specific reason to do so.  Ethernet drivers will not
have such a reason.

This is a very bad trend and I think I'm going to need to simply
remove the ->select_queue() method to stop the bleeding.

If people keep overriding this method in their drivers, then when we
move to more sophisticated methods of computing the hash we will have
to hit all of these override spots which makes the generic queue
selection function pointless.
