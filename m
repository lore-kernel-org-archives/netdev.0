From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [bug, 2.6.24-rc1] sysfs: duplicate filename 'eth0' can not be
 created
Date: Mon, 29 Oct 2007 17:35:11 -0400
Message-ID: <4726520F.1020605@garzik.org>
References: <20071029211746.GA19876@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58337 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755127AbXJ2VfO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 17:35:14 -0400
In-Reply-To: <20071029211746.GA19876@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Molnar wrote:
> hm, this seems to have popped up in the last few days, never had it 
> before:
> 
>   sysfs: duplicate filename 'eth0' can not be created
>   WARNING: at fs/sysfs/dir.c:424 sysfs_add_one()
> 
>   Call Trace:
>    [<ffffffff802de00a>] sysfs_add_one+0x54/0xbd
>    [<ffffffff802dee61>] sysfs_create_link+0xc6/0x11d
>    [<ffffffff8047c491>] device_rename+0x175/0x1d6
>    [<ffffffff806180a6>] dev_change_name+0x118/0x211
>    [<ffffffff8061893c>] dev_ioctl+0x4fa/0x5f8
>    [<ffffffff8062eb11>] netlink_insert+0x13c/0x14b
>    [<ffffffff806a877f>] do_page_fault+0x3eb/0x73f
>    [<ffffffff8060b909>] sock_ioctl+0x1f2/0x200
>    [<ffffffff802a5a5d>] do_ioctl+0x21/0x6b
>    [<ffffffff802a5cea>] vfs_ioctl+0x243/0x25c
>    [<ffffffff802a5d54>] sys_ioctl+0x51/0x71
>    [<ffffffff8020c02e>] system_call+0x7e/0x83
> 
>    net eth0: device_rename: sysfs_create_symlink failed (-17)
> 
> 32-bit bzImage kernel - config attached. (The 64-bit kernel even lost 
> connectivity due to this and ifcfg-eth0 got renamed to ifcfg-eth0.bak by 
> kudzu.)
> 
> detected order of the interfaces is:
> 
>   forcedeth 0000:00:0a.0: ifname eth0, PHY OUI 0x5043 @1
>   eth1: RealTek RTL8139 at 0xffffc200001f2000
> 
> and that's the ordering in /etc/sysconfig/network-scripts as well.

Does your setup do anything like try to rename the interfaces?

I cannot think of anything that changed recently in this area in net, 
off the top of my head.

	Jeff



