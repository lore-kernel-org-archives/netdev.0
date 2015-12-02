From: Pavel Fedin <p.fedin@samsung.com>
Subject: RE: [PATCH 3/6] net: thunderx: Increase transmit queue length
Date: Wed, 02 Dec 2015 13:31:42 +0300
Message-ID: <00eb01d12cec$a32aa500$e97fef00$@samsung.com>
References: <y@samsung.com>
 <1448961223-41888-4-git-send-email-sunil.kovvuri@gmail.com>
 <01d101d12c46$2de43b40$89acb1c0$@samsung.com>
 <1448983985.25582.35.camel@edumazet-glaptop2.roam.corp.google.com>
 <CA+sq2Ce9oH-kCDO8hK_wX+ZZdXyyBuT4V2bt5Ab+2=pEX+BO+w@mail.gmail.com>
 <00cb01d12ce0$9f090540$dd1b0fc0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: 'Linux Netdev List' <netdev@vger.kernel.org>,
	'LKML' <linux-kernel@vger.kernel.org>,
	'LAKML' <linux-arm-kernel@lists.infradead.org>,
	'Sunil Goutham' <Sunil.Goutham@caviumnetworks.com>,
	'Sunil Goutham' <sgoutham@cavium.com>
To: 'Sunil Kovvuri' <sunil.kovvuri@gmail.com>,
	'Eric Dumazet' <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <00cb01d12ce0$9f090540$dd1b0fc0$@samsung.com>
Content-language: ru
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Hello!

> > Probably you might have to set "coherent_pool" size in bootargs to a
> > higher value.
> > Can you please check.
> 
>  I have tried to do this. I was able to enlarge the pool up to 4MB, and still got allocation
> failures. At 8MB pool preallocation stops working:
> --- cut ---
> Call trace:
> [<ffffffc00012ddb8>] __alloc_pages_nodemask+0x4f4/0x7d4
> [<ffffffc0007be370>] atomic_pool_init+0x60/0x1a4
> [<ffffffc0007be4d4>] arm64_dma_init+0x20/0x28
> [<ffffffc000082848>] do_one_initcall+0x8c/0x1a4
> [<ffffffc0007baac0>] kernel_init_freeable+0x154/0x1f4
> [<ffffffc0005c2b14>] kernel_init+0x10/0xd8
> DMA: failed to allocate 8192 KiB pool for atomic coherent allocation
> --- cut ---
>  and i get even worse faults in the driver.
> 
>  I know that it is possible to allocate larger pools by setting CONFIG_FORCE_MAX_ZONEORDER,
> but:
> a) This is done on per-platform basis. For ThunderX we used to have a patch
> (http://www.spinics.net/lists/arm-kernel/msg415457.html), which never made it upstream,
> because vGIC fixes stopped requiring it at some point. And also we may want to use the nicvf
> driver not only on actual hardware, but also inside virtual machine in KVM. So do we need to
> set CONFIG_FORCE_MAX_ZONEORDER for virt too? And what if at some point qemu emulates not only
> "virt", but some other machine (let's say AMD X-Gene), and we run it on ThunderX and want to
> use nicvf with this model?
> b) IMHO it's not good to have a driver which simply does not work without some obscure option
> in boot arguments.
> 
>  So, i see several possible ways to solve this:
> 
> 1. Introduce some mechanism which would allow the driver to tell the kernel that it needs
> coherent pool of large size. Can be problematic because the driver can be a module, and pool
> allocation happens early.
> 2. Can we use some other method for allocating queues, which would not require such a huge
> coherent pool?
> 3. The driver could check value of atomic_pool_size and adjust own memory requirements
> accordingly. This indeed looks like a quick hack, but would at least make things running
> quickly.

 I have also noticed that CONFIG_DMA_CMA is turned off in my kernel. I guess it was a leftover from old defconfig, because i carry over my .config from version to version. I enabled it and rebuilt the kernel, but in order to get the driver working with this patch i had to also add cma=32M option to kernel arguments. With default of 16M the allocation still fails.
 Should we add Kconfig dependencies?

Kind regards,
Pavel Fedin
Expert Engineer
Samsung Electronics Research center Russia
