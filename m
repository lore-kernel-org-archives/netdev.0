From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vxlan: fix test which detect duplicate vxlan iface
Date: Sat, 09 Jan 2016 21:05:09 -0500 (EST)
Message-ID: <20160109.210509.939212619090970717.davem@davemloft.net>
References: <1452162413-4227-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50145 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756607AbcAJCFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2016 21:05:11 -0500
In-Reply-To: <1452162413-4227-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu,  7 Jan 2016 11:26:53 +0100

> When a vxlan interface is created, the driver checks that there is not
> another vxlan interface with the same properties. To do this, it checks
> the existing vxlan udp socket. Since commit 1c51a9159dde, the creation of
> the vxlan socket is done only when the interface is set up, thus it breaks
> that test.
> 
> Example:
> $ ip l a vxlan10 type vxlan id 10 group 239.0.0.10 dev eth0 dstport 0
> $ ip l a vxlan11 type vxlan id 10 group 239.0.0.10 dev eth0 dstport 0
> $ ip -br l | grep vxlan
> vxlan10          DOWN           f2:55:1c:6a:fb:00 <BROADCAST,MULTICAST>
> vxlan11          DOWN           7a:cb:b9:38:59:0d <BROADCAST,MULTICAST>
> 
> Instead of checking sockets, let's loop over the vxlan iface list.
> 
> Fixes: 1c51a9159dde ("vxlan: fix race caused by dropping rtnl_unlock")
> Reported-by: Thomas Faivre <thomas.faivre@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied and queued up for -stable, thanks.
