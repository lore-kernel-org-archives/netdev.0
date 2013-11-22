From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Doubt on Implict BUGs caused LRO] doubt about lro status in
 v3.12 of torvalds/linux.git
Date: Fri, 22 Nov 2013 08:32:52 -0800
Message-ID: <1385137972.10637.86.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAJULonje7V_sMt6joBBsM3uuQkYFhfNK70BXzN0EyS3sQNb0uQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	China Kernel <kernel@vger.linux-kernel.cn>,
	linux-kernel@vger.kernel.org
To: Yanfei Wang <backyes@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJULonje7V_sMt6joBBsM3uuQkYFhfNK70BXzN0EyS3sQNb0uQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-11-22 at 23:00 +0800, Yanfei Wang wrote:
> Hi,
> 
> Compared to the earlier kernel version, I found that Large receive
> offload(LRO) is obsolete in latest kernel, and that is verified from
> other materials about Generic receive offload(GRO).
> 
> However,  I also found some LRO header files and  lro-related
> functions referred by some drivers, and the lro-related function
> definition is already removed at the same time!
> 
> TEST steps:
> 1. my git local db config as follow, url =
> http://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
> 2. git checkout v3.12 -b 3.12
> 3. cd net/ipv4,
>  [backyes@f14 ipv4]$ cat Makefile | grep lro
> obj-$(CONFIG_INET_LRO) += inet_lro.o
> [backyes@f14 ipv4]$ ls inet_*
> inet_connection_sock.c  inet_diag.c  inet_fragment.c
> inet_hashtables.c  inet_timewait_sock.c
> [backyes@f14 ipv4]$
> Here, Makefile has inet_lro.o config, while the inet_lro.c is removed.
> 4. lro functions referred by some drivers, as follow,
> [backyes@f14 linux]$ grep "inet_lro" * -r
> drivers/net/ethernet/pasemi/pasemi_mac.c:#include <linux/inet_lro.h>
> drivers/net/ethernet/pasemi/pasemi_mac_ethtool.c:#include <linux/inet_lro.h>
> drivers/infiniband/hw/nes/nes_hw.c:#include <linux/inet_lro.h>
> drivers/infiniband/hw/nes/nes_hw.h:#include <linux/inet_lro.h>
> include/linux/inet_lro.h: *  linux/include/linux/inet_lro.h
> net/ipv4/Makefile:obj-$(CONFIG_INET_LRO) += inet_lro.o
> 
> so, I understand that the removal of LRO is not clean, which will
> cause compiler error for some kernel config.
> 

I think you are slightly confused.

LRO is not yet removed.

Feel free to contribute ;)

As long as at least one driver still uses LRO, we can not remove LRO.

Converting a driver means testing the new driver, and owning the
hardware.
