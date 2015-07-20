From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bonding: correctly handle bonding type change on
 enslave failure
Date: Mon, 20 Jul 2015 16:23:29 -0700 (PDT)
Message-ID: <20150720.162329.1291501032199854301.davem@davemloft.net>
References: <1436993821-4114-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, monis@voltaire.com, j.vosburgh@gmail.com,
	gospo@cumulusnetworks.com, vfalico@gmail.com,
	nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52407 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753809AbbGTXXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 19:23:30 -0400
In-Reply-To: <1436993821-4114-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Wed, 15 Jul 2015 22:57:01 +0200

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> If the bond is enslaving a device with different type it will be setup
> by it, but if after being setup the enslave fails the bond doesn't
> switch back its type and also keeps pointers to foreign structures that can
> be long gone. Thus revert back any type changes if the enslave failed and
> the bond had to change its type.
> Example:
>  Before patch:
> $ echo lo > bond0/bonding/slaves
> -bash: echo: write error: Cannot assign requested address
> $ ip l sh bond0
> 20: bond0: <BROADCAST,MULTICAST,MASTER> mtu 1500 qdisc noop state DOWN
> mode DEFAULT group default
>     link/loopback 16:54:78:34:bd:41 brd 00:00:00:00:00:00
> $ echo +eth1 > bond0/bonding/slaves
> $ ip l sh bond0
> 20: bond0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode
> DEFAULT group default qlen 1000
>     link/ether 52:54:00:3f:47:69 brd ff:ff:ff:ff:ff:ff
> (notice the MASTER flag is gone)
> 
>  After patch:
> $ echo lo > bond0/bonding/slaves
> -bash: echo: write error: Cannot assign requested address
> $ ip l sh bond0
> 21: bond0: <BROADCAST,MULTICAST,MASTER> mtu 1500 qdisc noop state DOWN
> mode DEFAULT group default qlen 1000
>     link/ether 6e:66:94:f6:07:fc brd ff:ff:ff:ff:ff:ff
> $ echo +eth1 > bond0/bonding/slaves
> $ ip l sh bond0
> 21: bond0: <BROADCAST,MULTICAST,MASTER> mtu 1500 qdisc noop state DOWN
> mode DEFAULT group default qlen 1000
>     link/ether 52:54:00:3f:47:69 brd ff:ff:ff:ff:ff:ff
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Fixes: e36b9d16c6a6 ("bonding: clean muticast addresses when device changes type")

Applied.
