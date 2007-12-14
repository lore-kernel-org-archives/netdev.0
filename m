From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] HDLC driver: use unregister_netdev instead of
 unregister_netdevice
Date: Fri, 14 Dec 2007 13:36:22 -0800 (PST)
Message-ID: <20071214.133622.51765106.davem@davemloft.net>
References: <475F490C.2020305@cn.fujitsu.com>
	<m3ve71t194.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wangchen@cn.fujitsu.com, jgarzik@pobox.com, netdev@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60283
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752718AbXLNVgY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 16:36:24 -0500
In-Reply-To: <m3ve71t194.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Fri, 14 Dec 2007 22:28:07 +0100

> Wang Chen <wangchen@cn.fujitsu.com> writes:
> 
> > [PATCH] HDLC driver: use unregister_netdev instead of unregister_netdevice
> >
> > Since the caller and the upper caller doesn't hod the rtnl semaphore.
> > We should use unregister_netdev instead of unregister_netdevice.
> 
> NAK, not-a-bug. The caller actually holds rtnl, it goes through
> the netdev core ioctl dispatcher:
> 
> (unregister_netdevice+0x0/0x24) from (fr_ioctl+0x688/0x75c)
> /* fr_del_pvc() and fr_add_pvc() optimized out by gcc */
> (fr_ioctl+0x0/0x75c) from (hdlc_ioctl+0x4c/0x8c)
> (hdlc_ioctl+0x0/0x8c) from (hss_ioctl+0x3c/0x324)
> (hss_ioctl+0x0/0x324) from (dev_ifsioc+0x428/0x4e8)
> (dev_ifsioc+0x0/0x4e8) from (dev_ioctl+0x5d8/0x664)
> (dev_ioctl+0x0/0x664) from (sock_ioctl+0x90/0x254)
> (sock_ioctl+0x0/0x254) from (do_ioctl+0x34/0x78)
> (do_ioctl+0x0/0x78) from (vfs_ioctl+0x78/0x2a8)
> (vfs_ioctl+0x0/0x2a8) from (sys_ioctl+0x40/0x64)
> (sys_ioctl+0x0/0x64) from (ret_fast_syscall+0x0/0x2c)
> 
> The patch would make it deadlock.

Ok, I'll drop this patch, thanks for checking.
