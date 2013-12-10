From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH for-next] mlx4_core: Roll back round robin bitmap
 allocation commit for CQs, SRQs, and MPTs
Date: Mon, 09 Dec 2013 21:12:33 -0500 (EST)
Message-ID: <20131209.211233.415056494606198185.davem@davemloft.net>
References: <1386514217-23739-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vlad-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org
To: ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1386514217-23739-1-git-send-email-ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Date: Sun,  8 Dec 2013 16:50:17 +0200

> From: Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
> 
> Commit f4ec9e9 "mlx4_core: Change bitmap allocator to work in round-robin fashion" 
> introduced round-robin allocation (via bitmap) for all resources which allocate 
> via a bitmap.
> 
> Round robin allocation is desirable for mcgs, counters, pd's, UARs, and xrcds.
> These are simply numbers, with no involvement of ICM memory mapping.
> 
> Round robin is required for QPs, since we had a problem with immediate
> reuse of a 24-bit QP number (commit f4ec9e9).
> 
> However, for other resources which use the bitmap allocator and involve
> mapping ICM memory -- MPTs, CQs, SRQs -- round-robin is not desirable.
> 
> What happens in these cases is the following:
> 
> ICM memory is allocated and mapped in chunks of 256K.
> 
> Since the resource allocation index goes up monotonically, the allocator
> will eventually require mapping a new chunk. Now, chunks are also unmapped
> when their reference count goes back to zero.  Thus, if a single app is
> running and starts/exits frequently we will have the following situation:
> 
> When the app starts, a new chunk must be allocated and mapped.
> 
> When the app exits, the chunk reference count goes back to zero, and the
> chunk is unmapped and freed. Therefore, the app must pay the cost of allocation
> and mapping of ICM memory each time it runs (although the price is paid only when
> allocating the initial entry in the new chunk).
> 
> For apps which allocate MPTs/SRQs/CQs and which operate as described above,
> this presented a performance problem.
> 
> We therefore roll back the round-robin allocator modification for MPTs, CQs, SRQs.
> 
> Reported-by: Matthew Finlay <matt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
> Signed-off-by: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
