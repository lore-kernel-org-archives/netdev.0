From: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next] net/mlx4_core: Fix backward compatibility on VFs
Date: Mon, 21 Mar 2016 15:56:30 +0200
Message-ID: <20160321135630.GA95906@x-vnc01.mtx.labs.mlnx>
References: <1458233382-12871-1-git-send-email-eli@mellanox.com>
 <56EBCE2F.40902@ozlabs.ru>
 <56EF8058.2060203@ozlabs.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexey Kardashevskiy <aik-sLpHqDYs0B2HXe+LvDLADg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <56EF8058.2060203-sLpHqDYs0B2HXe+LvDLADg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 21, 2016 at 04:02:16PM +1100, Alexey Kardashevskiy wrote:
> 
> After more tries, I found that if for whatever reason mlx4_core
> fails to stop while shutting the guest down (last message is
> "mlx4_core 0000:00:00.0: mlx4_shutdown was called"), then next time
> VF in guest won't start.
> 
> Example #1:
> 
> mlx4_core: Mellanox ConnectX core driver v2.2-1 (Feb, 2014)
> mlx4_core: Initializing 0000:00:00.0
> mlx4_core 0000:00:00.0: enabling device (0000 -> 0002)
> mlx4_core 0000:00:00.0: Detected virtual function - running in slave mode
> mlx4_core 0000:00:00.0: Sending reset
> mlx4_core 0000:00:00.0: Sending vhcr0
> mlx4_core 0000:00:00.0: HCA minimum page size:1
> mlx4_core 0000:00:00.0: UAR size:4096 != kernel PAGE_SIZE of 65536
> mlx4_core 0000:00:00.0: Failed to obtain slave caps

Alexey, can you verify that the value of the enable_4k_uar parameter
is false?

> 
> Example #2:
> 
> root@le-dbg:~# dhclient eth0
> NETDEV WATCHDOG: eth0 (mlx4_core): transmit queue 11 timed out
> ------------[ cut here ]------------
> WARNING: at /home/aik/p/guest-kernel/net/sched/sch_generic.c:303
> 
> and no IP assigned, timed out.
> 
> 
> This is fixed by the guest restart, first restart might not help,
> then the second restart will.
> 
> The host is running the latest upstream plus the patch I am replying
> to. The guest is using initramdisk from debian bootstrap and vanilla
> v4.2 kernel, ppc64le arch, POWER8 chip, QEMU is running with 1 CPU
> and 2GB of RAM.
> 
> Does this look any familiar?
>

This is completely unrelated to the compatibility problem you reported
and which this patch addresses. We will reproduce in house and post a
fix.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
