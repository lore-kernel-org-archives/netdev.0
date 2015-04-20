From: Eli Cohen <eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [PATCH linux-next v5] mlx5: wrong page mask if
 CONFIG_ARCH_DMA_ADDR_T_64BIT enabled for 32Bit architectures
Date: Mon, 20 Apr 2015 10:48:48 +0300
Message-ID: <20150420074848.GA17506@mtldesk30>
References: <1429086975-15506-1-git-send-email-honli@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Honggang Li <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1429086975-15506-1-git-send-email-honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 15, 2015 at 04:36:15PM +0800, Honggang Li wrote:
> If CONFIG_ARCH_DMA_ADDR_T_64BIT enabled for x86 systems and physical
> memory is more than 4GB, dma_map_page may return a valid memory
> address which greater than 0xffffffff. As a result, the mlx5 device page
> allocator RB tree will be initialized with valid addresses greater than
> 0xfffffff.
> 
> However, (addr & PAGE_MASK) set the high four bytes to zeros. So, it's
> impossible for the function, free_4k, to release the pages whose
> addresses greater than 4GB. Memory leaks. And mlx5_ib module can't
> release the pages when user try to remove the module, as a result,
> system hang.
> 
> [root@rdma05 root]# dmesg  | grep addr | head
> addr             = 3fe384000
> addr & PAGE_MASK =  fe384000
> [root@rdma05 root]# rmmod mlx5_ib   <---- hang on
> 
> ---------------------- cosnole log -----------------
> mlx5_ib 0000:04:00.0: irq 138 for MSI/MSI-X
>   alloc irq_desc for 139 on node -1
>   alloc kstat_irqs on node -1
> mlx5_ib 0000:04:00.0: irq 139 for MSI/MSI-X
> 0000:04:00.0:free_4k:221:(pid 1519): page not found
> 0000:04:00.0:free_4k:221:(pid 1519): page not found
> 0000:04:00.0:free_4k:221:(pid 1519): page not found
> 0000:04:00.0:free_4k:221:(pid 1519): page not found
> ---------------------- cosnole log -----------------
> 
> Fixes: bf0bf77f6519 ('mlx5: Support communicating arbitrary host page size to firmware')
> Signed-off-by: Honggang Li <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---

Acked-by: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
