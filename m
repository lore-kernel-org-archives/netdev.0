From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next]netdevice: 82596: Convert netdev->priv to
 netdev_priv
Date: Sun, 16 Nov 2008 22:36:37 -0800 (PST)
Message-ID: <20081116.223637.108010315.davem@davemloft.net>
References: <4921095D.9010109@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45691
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752554AbYKQGgh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 01:36:37 -0500
In-Reply-To: <4921095D.9010109@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Mon, 17 Nov 2008 14:04:13 +0800

> -#ifdef __mc68000__
> -	cache_push(virt_to_phys((void *)(dev->mem_start)), 4096);
> -	cache_clear(virt_to_phys((void *)(dev->mem_start)), 4096);
> -	kernel_set_cachemode((void *)(dev->mem_start), 4096, IOMAP_NOCACHE_SER);
> -#endif

Do you have any idea what this code is doing that you are removing?

It's changing the cache mode of the memory behind ->mem_start because
this "lp" struct is directly accessed by the hardware, and without
these operations the CPU and the device won't see consistent
values in the structure.

Therefore your change breaks the driver.
