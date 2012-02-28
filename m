From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] mlx4: prevent the device from being removed
 concurrently
Date: Tue, 28 Feb 2012 14:30:51 -0500 (EST)
Message-ID: <20120228.143051.352474620462899753.davem@davemloft.net>
References: <1330454176-17768-1-git-send-email-cascardo@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org
To: cascardo-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1330454176-17768-1-git-send-email-cascardo-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Thadeu Lima de Souza Cascardo <cascardo-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Tue, 28 Feb 2012 15:36:16 -0300

> When a EEH happens, the catas poll code will try to restart the device,
> removing it and adding it back again. The EEH code will try to do the
> same. One of the threads ends up accessing memory that was freed by the
> other thread and we get a crash.

Stop adding bandaids to the locking.

If the EEH infrastructure doesn't synchronize parallel operations
on the same device, that is the real bug, and that's where the real
fix belongs.

I refuse to apply this patch.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
