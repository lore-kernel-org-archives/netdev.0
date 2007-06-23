From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: Sat, 23 Jun 2007 18:25:09 +0200
Message-ID: <467D4965.40601@trash.net>
References: <20070622034452.28886.0@janus.isnogud.escape.de>	<20070622034703.28886.5@janus.isnogud.escape.de>	<467BAC48.1070700@trash.net> <ygfk5tw41rq.fsf@janus.isnogud.escape.de> <467BC2AF.8080901@trash.net> <467D0C97.1000000@hartkopp.net> <467D178B.8080503@trash.net> <467D3891.4010906@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, j.hadi123@gmail.com,
	Urs Thuermann <urs@isnogud.escape.de>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	netdev@vger.kernel.org
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56231 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752378AbXFWQZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2007 12:25:24 -0400
In-Reply-To: <467D3891.4010906@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oliver Hartkopp wrote:
> @Patrick: The changes in dummy.c and ifb.c for the netlink support do
> not look very complicated (not even for me ;-))


I have a patch to make it even simpler, it basically needs only
the rtnl_link_ops structures initialized with one or two members
for devices like dummy and ifb. Will push once we're through the
patches I sent recently, until then please use the current interface.

> When these changes are
> implemented, how do i create/remove my interfaces? Is there any
> userspace tool like 'tc' for that?


Its "ip". I think I've CCed you or one of your colleagues on
the patches, otherwise please check the list. For a device like
yours it only needs the patch implementing general RTM_NEWLINK
support, unless you want to make the loopback parameter
configurable, in which case you would need to add something
like iplink_vlan that parses the parameter.

BTW, in case the loopback device is required for normal
operation it might make sense to create *one* device by
default, but four identical devices seems a bit extreme.

