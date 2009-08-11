From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 13954] New: Oops in rtnetlink code when creating
 can device
Date: Tue, 11 Aug 2009 10:22:20 +0200
Message-ID: <4A812A3C.10207@trash.net>
References: <bug-13954-10286@http.bugzilla.kernel.org/> <20090810215436.0bf47297.akpm@linux-foundation.org> <4A812354.8090704@volkswagen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Wolfgang Grandegger <wg@grandegger.com>, dbaryshkov@gmail.com,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	"Thuermann, Urs, Dr. (K-EFFI/I)" <urs.thuermann@volkswagen.de>,
	Lothar Wassmann <LW@KARO-electronics.de>,
	netdev@vger.kernel.org
To: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64684 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753078AbZHKMgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2009 08:36:32 -0400
In-Reply-To: <4A812354.8090704@volkswagen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Hartkopp wrote:
>>> I've got a nice oops when looking around new CAN code in kernel.
>>>
>>> root@qemux86:~# ip link add type can
>>> [  713.113325] BUG: unable to handle kernel NULL pointer dereference
>>> at (null)
>>> [  713.114216] IP: [<c13eecab>] register_netdevice+0xab/0x420
>>> ...
> The problem is, that
> 
> ip link add type can
> 
> is not possible as you can not create 'real' CAN devices like can0,
> can1, ...
> 
> To create 'software CAN devices' like vcan0, vcan1, vcan2, ... we use
> 
> ip link add type vcan
> 
> see drivers/net/can/vcan.c
> 
> ---
> 
> For real hardware CAN devices the netlink interface is only used for the
> configuration of already existing interfaces.
> From a quick view on the rtnl_newlink() function in net/core/rtnetlink.c
> i was not able to find any method to disallow the creation of 
> interfaces, will say: How can a netlink user provide the information,
> that he's not able to create new devices via netlink???
> 
> @Patrick: Do you have an idea for this? Is it a new use-case for netlink
> that needs to be implemented?

You could add a ->newlink() function that unconditionally returns
an error.
