From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] bnx2: fix locking when netconsole is used
Date: Tue, 18 Oct 2016 10:24:56 -0400 (EDT)
Message-ID: <20161018.102456.2192831343851897913.davem@davemloft.net>
References: <1476771363-3552-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
        Dept-HSGLinuxNICDev@qlogic.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42098 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761517AbcJROZF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 10:25:05 -0400
In-Reply-To: <1476771363-3552-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Tue, 18 Oct 2016 08:16:03 +0200

> Functions bnx2_reg_rd_ind(), bnx2_reg_wr_ind() and bnx2_ctx_wr()
> can be called with IRQs disabled when netconsole is enabled. So they
> should use spin_{,un}lock_irq{save,restore} instead of _bh variants.
> 
> Example call flow:
> bnx2_poll()
>   ->bnx2_poll_link()
>     ->bnx2_phy_int()
>       ->bnx2_set_remote_link()
>         ->bnx2_shmem_rd()
>           ->bnx2_reg_rd_ind()
>             -> spin_lock_bh(&bp->indirect_lock);
>                spin_unlock_bh(&bp->indirect_lock);
>                ...
>                -> __local_bh_enable_ip
> 
> static inline void __local_bh_enable_ip(unsigned long ip)
>       WARN_ON_ONCE(in_irq() || irqs_disabled());   <<<<<< WARN
> 
> Cc: Sony Chacko <sony.chacko@qlogic.com>
> Cc: Dept-HSGLinuxNICDev@qlogic.com
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Applied, thanks Ivan.
