From: Jon Nettleton <jon@solid-run.com>
Subject: Re: [PATCH] net: mvneta: fix open() error cleanup
Date: Fri, 1 Jul 2016 09:34:00 +0200
Message-ID: <CABdtJHsGzNVpP11DL91XQ9ZKX2FWTgjRU+w29zU1+T7kmw3fsw@mail.gmail.com>
References: <20160630093615.GK1041@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:34924 "EHLO
	mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003AbcGAHeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 03:34:04 -0400
Received: by mail-lf0-f67.google.com with SMTP id w130so10569728lfd.2
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 00:34:02 -0700 (PDT)
In-Reply-To: <20160630093615.GK1041@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 30, 2016 at 11:36 AM, Russell King - ARM Linux
<linux@armlinux.org.uk> wrote:
> If mvneta_mdio_probe() fails, a kernel warning is triggered due to
> missing cleanup in the error path.  Add the necessary cleanup.
>
> ------------[ cut here ]------------
> WARNING: CPU: 1 PID: 281 at kernel/irq/manage.c:1814 __free_percpu_irq+0xfc/0x130
> percpu IRQ 38 still enabled on CPU0!
> Modules linked in: bnep bluetooth xhci_plat_hcd xhci_hcd marvell_cesa armada_thermal des_generic ehci_orion mcp3021 spi_orion sfp mdio_i2c evbug fuse
> CPU: 1 PID: 281 Comm: connmand Not tainted 4.7.0-rc2+ #53
> Hardware name: Marvell Armada 380/385 (Device Tree)
> Backtrace:
> [<c0013488>] (dump_backtrace) from [<c00137d0>] (show_stack+0x18/0x1c)
>  r6:60010093 r5:ffffffff r4:00000000 r3:dc8ba500
> [<c00137b8>] (show_stack) from [<c02c6fe0>] (dump_stack+0xa4/0xdc)
> [<c02c6f3c>] (dump_stack) from [<c002d4ec>] (__warn+0xd8/0x104)
>  r6:c081e6a0 r5:00000000 r4:edfe5d50 r3:dc8ba500
> [<c002d414>] (__warn) from [<c002d5d0>] (warn_slowpath_fmt+0x40/0x48)
>  r10:a0010013 r8:c09356f8 r7:00000026 r6:ef11a260 r5:edd7b980 r4:ef11a200
> [<c002d594>] (warn_slowpath_fmt) from [<c008c8e0>] (__free_percpu_irq+0xfc/0x130)
>  r3:00000026 r2:c081e7ac
> [<c008c7e4>] (__free_percpu_irq) from [<c008c95c>] (free_percpu_irq+0x48/0x74)
>  r10:00008914 r8:00000000 r7:ffffffed r6:c09356f8 r5:00000026 r4:ef11a200
> [<c008c914>] (free_percpu_irq) from [<c043dd70>] (mvneta_open+0x118/0x134)
>  r6:ffffffed r5:ef01e640 r4:ef01e000 r3:ef01e000
> [<c043dc58>] (mvneta_open) from [<c055f5b4>] (__dev_open+0xa4/0x108)
>  r7:ef01e030 r6:c06ff3d8 r5:ffff9003 r4:ef01e000
> [<c055f510>] (__dev_open) from [<c055f844>] (__dev_change_flags+0x94/0x150)
>  r7:00001002 r6:00000001 r5:ffff9003 r4:ef01e000
> [<c055f7b0>] (__dev_change_flags) from [<c055f938>] (dev_change_flags+0x20/0x50)
>  r8:00000000 r7:c09334c8 r6:00001002 r5:00000148 r4:ef01e000 r3:00008914
> [<c055f918>] (dev_change_flags) from [<c05de044>] (devinet_ioctl+0x6f4/0x7e0)
>  r8:00000000 r7:c09334c8 r6:00000000 r5:ee87200c r4:00000000 r3:00008914
> [<c05dd950>] (devinet_ioctl) from [<c05e0168>] (inet_ioctl+0x1b8/0x1c8)
>  r10:beb4499c r9:edfe4000 r8:ecf13280 r7:c096cf00 r6:beb4499c r5:eef7c240
>  r4:00008914
> [<c05dffb0>] (inet_ioctl) from [<c053c898>] (sock_ioctl+0x78/0x300)
> [<c053c820>] (sock_ioctl) from [<c0155ecc>] (do_vfs_ioctl+0x98/0xa60)
>  r7:00000011 r6:00008914 r5:00000011 r4:c01568d0
> [<c0155e34>] (do_vfs_ioctl) from [<c01568d0>] (SyS_ioctl+0x3c/0x60)
>  r10:00000000 r9:edfe4000 r8:beb4499c r7:00000011 r6:00008914 r5:ecf13280
>  r4:ecf13280
> [<c0156894>] (SyS_ioctl) from [<c000fe60>] (ret_fast_syscall+0x0/0x1c)
>  r8:c0010004 r7:00000036 r6:00000011 r5:000a2978 r4:00000000 r3:00009003
> ---[ end trace 711f625d5b04b3a7 ]---
>
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
> ---
> I've omitted a Fixes: line because it's not just one commit, but many
> as the code has gone through a number of transformations here, but the
> bug has been present for a long time.  The first commit suitable for
> this patch is 6b125d63b7f6 ("net: mvneta: Use on_each_cpu when
> possible")
>
>  drivers/net/ethernet/marvell/mvneta.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
> index b04380896a94..c59e9295a7e5 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -3570,6 +3570,8 @@ static int mvneta_open(struct net_device *dev)
>         return 0;
>
>  err_free_irq:
> +       unregister_cpu_notifier(&pp->cpu_notifier);
> +       on_each_cpu(mvneta_percpu_disable, pp, true);
>         free_percpu_irq(pp->dev->irq, pp->ports);
>  err_cleanup_txqs:
>         mvneta_cleanup_txqs(pp);
>
> --
> RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
> FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
> according to speedtest.net.

Tested-by: Jon Nettleton <jon@solid-run.com>
