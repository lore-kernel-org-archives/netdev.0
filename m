From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH linux-next v2] mlx5: wrong page mask if
 CONFIG_ARCH_DMA_ADDR_T_64BIT enabled for 32Bit architectures
Date: Tue, 14 Apr 2015 14:05:46 -0400 (EDT)
Message-ID: <20150414.140546.1390992213156919928.davem@davemloft.net>
References: <1428916918-24404-1-git-send-email-honli@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eli@mellanox.com, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
To: honli@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36448 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752859AbbDNSFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 14:05:49 -0400
In-Reply-To: <1428916918-24404-1-git-send-email-honli@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Honggang Li <honli@redhat.com>
Date: Mon, 13 Apr 2015 17:21:58 +0800

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
> Signed-off-by: Honggang Li <honli@redhat.com>

Please someone at Mellanox review this.
