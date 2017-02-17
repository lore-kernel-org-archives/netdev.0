From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vmxnet3: prevent building with 64K pages
Date: Fri, 17 Feb 2017 15:27:51 -0500 (EST)
Message-ID: <20170217.152751.774490769271193769.davem@davemloft.net>
References: <20170217150847.2505538-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: skhare@vmware.com, pv-drivers@vmware.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170217150847.2505538-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 17 Feb 2017 16:08:30 +0100

> I got a warning about broken code on ARM64 with 64K pages:
> 
> drivers/net/vmxnet3/vmxnet3_drv.c: In function 'vmxnet3_rq_init':
> drivers/net/vmxnet3/vmxnet3_drv.c:1679:29: error: large integer implicitly truncated to unsigned type [-Werror=overflow]
>     rq->buf_info[0][i].len = PAGE_SIZE;
> 
> 'len' here is a 16-bit integer, so this clearly won't work. I don't think
> this driver is used much on anything other than x86, so there is no need
> to fix this properly and we can work around it with a Kconfig dependency
> to forbid known-broken configurations. qemu in theory supports it on
> other architectures too, but presumably only for compatibility with x86
> guests that also run on vmware.
> 
> CONFIG_PAGE_SIZE_64KB is used on hexagon, mips, sh and tile, the other
> symbols are architecture-specific names for the same thing.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

I've applied this to net-next, but...

That is a real messy plethora of Kconfig symbol variants, it would be nice
to consolidate those somehow.

The driver could also chop 64K pages into 32K or smaller pieces and
maintain an appropriate refcnt.  Yes, I realize this is probably not
very valuable work for a situation that might never ever occur.
