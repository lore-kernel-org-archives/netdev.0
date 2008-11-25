From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH -next/-mm/mainline] net/hp-plus: fix link errors
Date: Tue, 25 Nov 2008 09:59:52 -0800
Message-ID: <20081125095952.f25e8286.randy.dunlap@oracle.com>
References: <20081120211724.09b94026.randy.dunlap@oracle.com>
	<20081121.163335.255948683.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com,
	alan@lxorguk.ukuu.org.uk, akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:50712 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752168AbYKYSAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 13:00:55 -0500
In-Reply-To: <20081121.163335.255948683.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Nov 2008 16:33:35 -0800 (PST) David Miller wrote:

> From: Randy Dunlap <randy.dunlap@oracle.com>
> Date: Thu, 20 Nov 2008 21:17:24 -0800
> 
> > Fix hp-plus driver link errors.
> > Builds as loadable module and kernel image driver.
> > All drivers that use 8390.o or 8390p.o that will build on
> > i386 with MCA/PCI/EISA/ISA were built successfully both
> > =m and =y.
> > 
> > drivers/built-in.o: In function `hpp_open':
> > hp-plus.c:(.text+0xac06c): undefined reference to `eip_interrupt'
> > hp-plus.c:(.text+0xac0d7): undefined reference to `eip_open'
> > drivers/built-in.o: In function `hpp_close':
> > hp-plus.c:(.text+0xac1bb): undefined reference to `eip_close'
> > drivers/built-in.o: In function `hpp_probe1':
> > hp-plus.c:(.init.text+0xa98a): undefined reference to `NS8390p_init'
> > drivers/built-in.o: In function `hp_plus_probe':
> > (.init.text+0xa9fe): undefined reference to `__alloc_eip_netdev'
> > 
> > Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Applied, thanks Randy.
> --

Dave,
I'm seeing build problems (still/again) in linux-next like

WARNING: drivers/net/8390p: 'ei_set_multicast_list' exported twice. Previous export was in drivers/net/8390.ko
WARNING: drivers/net/8390p: 'ei_get_stats' exported twice. Previous export was in drivers/net/8390.ko
WARNING: drivers/net/8390p: 'ei_start_xmit' exported twice. Previous export was in drivers/net/8390.ko
WARNING: drivers/net/8390p: 'ei_tx_timeout' exported twice. Previous export was in drivers/net/8390.ko

and

build-r6464.out:(.text+0x1050): multiple definition of `ei_get_stats'
build-r6464.out:(.text+0x1150): multiple definition of `ei_start_xmit'
build-r6464.out:(.text+0xef0): multiple definition of `ei_tx_timeout'
build-r6464.out:(.text+0x1100): multiple definition of `ei_set_multicast_list'


which I guess (have not yet verified) are caused by this ($subject) patch.

You might want to drop/revert it until I see what's going on.

---
~Randy
