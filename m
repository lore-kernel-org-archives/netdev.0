From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] net/hsr: Fix NULL pointer dereference and
 refcnt bugs when deleting a HSR interface.
Date: Sun, 01 Mar 2015 14:00:51 -0500 (EST)
Message-ID: <20150301.140051.1600529369087381519.davem@davemloft.net>
References: <54F0D2DB.2020302@alten.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: arvid.brodin@alten.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43242 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753398AbbCATAx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 14:00:53 -0500
In-Reply-To: <54F0D2DB.2020302@alten.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arvid Brodin <arvid.brodin@alten.se>
Date: Fri, 27 Feb 2015 21:26:03 +0100

> To repeat:
> 
> $ sudo ip link del hsr0
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000018
> IP: [<ffffffff8187f495>] hsr_del_port+0x15/0xa0
> etc...
> 
> Bug description:
> 
> As part of the hsr master device destruction, hsr_del_port() is called for each of
> the hsr ports. At each such call, the master device is updated regarding features
> and mtu. When the master device is freed before the slave interfaces, master will
> be NULL in hsr_del_port(), which led to a NULL pointer dereference.
> 
> Additionally, dev_put() was called on the master device itself in hsr_del_port(),
> causing a refcnt error.
> 
> A third bug in the same code path was that the rtnl lock was not taken before
> hsr_del_port() was called as part of hsr_dev_destroy().
> 
> The reporter (Nicolas Dichtel) also said: "hsr_netdev_notify() supposes that the
> port will always be available when the notification is for an hsr interface. It's
> wrong. For example, netdev_wait_allrefs() may resend NETDEV_UNREGISTER.". As a
> precaution against this, a check for port == NULL was added in hsr_dev_notify().
> 
> Reported-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Fixes: 51f3c605318b056a ("net/hsr: Move slave init to hsr_slave.c.")
> Signed-off-by: Arvid Brodin <arvid.brodin@alten.se>

Applied.
