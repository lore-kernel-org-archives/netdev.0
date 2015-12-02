From: Pavel Fedin <p.fedin@samsung.com>
Subject: RE: [PATCH 3/6] net: thunderx: Increase transmit queue length
Date: Wed, 02 Dec 2015 15:29:10 +0300
Message-ID: <013301d12cfd$0c958a90$25c09fb0$@samsung.com>
References: <y@samsung.com>
 <1448961223-41888-4-git-send-email-sunil.kovvuri@gmail.com>
 <01d101d12c46$2de43b40$89acb1c0$@samsung.com>
 <1448983985.25582.35.camel@edumazet-glaptop2.roam.corp.google.com>
 <CA+sq2Ce9oH-kCDO8hK_wX+ZZdXyyBuT4V2bt5Ab+2=pEX+BO+w@mail.gmail.com>
 <00cb01d12ce0$9f090540$dd1b0fc0$@samsung.com>
 <00eb01d12cec$a32aa500$e97fef00$@samsung.com>
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
In-reply-to: <00eb01d12cec$a32aa500$e97fef00$@samsung.com>
Content-language: ru
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Hello!

> >  So, i see several possible ways to solve this:
> >
> > 1. Introduce some mechanism which would allow the driver to tell the kernel that it needs
> > coherent pool of large size. Can be problematic because the driver can be a module, and pool
> > allocation happens early.
> > 2. Can we use some other method for allocating queues, which would not require such a huge
> > coherent pool?
> > 3. The driver could check value of atomic_pool_size and adjust own memory requirements
> > accordingly. This indeed looks like a quick hack, but would at least make things running
> > quickly.
> 
>  I have also noticed that CONFIG_DMA_CMA is turned off in my kernel. I guess it was a leftover
> from old defconfig, because i carry over my .config from version to version. I enabled it and
> rebuilt the kernel, but in order to get the driver working with this patch i had to also add
> cma=32M option to kernel arguments. With default of 16M the allocation still fails.
>  Should we add Kconfig dependencies?

 After getting it working in guest i tried to apply it to host. With total of 128 virtual functions (= 128 interfaces) it does not work at all. Even after bumping cma region size to insane value of 2GB more than half of interfaces still failed to allocate queues. And after setting cma=3G i could not mount my rootfs.
 So, absolute NAK, unfortunately.

Kind regards,
Pavel Fedin
Expert Engineer
Samsung Electronics Research center Russia
