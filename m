From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v4] rtnl/bond: don't send rtnl msg for unregistered
 iface
Date: Sun, 17 May 2015 22:44:02 -0400 (EDT)
Message-ID: <20150517.224402.701978872263069371.davem@davemloft.net>
References: <20150512161402.GC2081@nanopsycho>
	<1431519582-4219-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50931 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751972AbbERCoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2015 22:44:04 -0400
In-Reply-To: <1431519582-4219-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed, 13 May 2015 14:19:42 +0200

> Before the patch, the command 'ip link add bond2 type bond mode 802.3ad'
> causes the kernel to send a rtnl message for the bond2 interface, with an
> ifindex 0.
> 
> 'ip monitor' shows:
> 0: bond2: <BROADCAST,MULTICAST,MASTER> mtu 1500 state DOWN group default
>     link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
> 9: bond2@NONE: <BROADCAST,MULTICAST,MASTER> mtu 1500 qdisc noop state DOWN group default
>     link/ether ea:3e:1f:53:92:7b brd ff:ff:ff:ff:ff:ff
> [snip]
> 
> The patch fixes the spotted bug by checking in bond driver if the interface
> is registered before calling the notifier chain.
> It also adds a check in rtmsg_ifinfo() to prevent this kind of bug in the
> future.
> 
> Fixes: d4261e565000 ("bonding: create netlink event when bonding option is changed")
> CC: Jiri Pirko <jiri@resnulli.us>
> Reported-by: Julien Meunier <julien.meunier@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied and queued up for -stable, thanks Nicolas.
