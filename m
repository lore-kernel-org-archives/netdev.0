From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlcnic: Fix a sleep-in-atomic bug in
 qlcnic_82xx_hw_write_wx_2M and qlcnic_82xx_hw_read_wx_2M
Date: Thu, 01 Jun 2017 11:42:30 -0400 (EDT)
Message-ID: <20170601.114230.1418496773053967971.davem@davemloft.net>
References: <1496305090-17814-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: harish.patil@cavium.com, manish.chopra@cavium.com,
        Dept-GELinuxNICDev@cavium.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: baijiaju1990@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56056 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751083AbdFAPmc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 11:42:32 -0400
In-Reply-To: <1496305090-17814-1-git-send-email-baijiaju1990@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jia-Ju Bai <baijiaju1990@163.com>
Date: Thu,  1 Jun 2017 16:18:10 +0800

> The driver may sleep under a write spin lock, and the function 
> call path is:
> qlcnic_82xx_hw_write_wx_2M (acquire the lock by write_lock_irqsave)
>   crb_win_lock
>     qlcnic_pcie_sem_lock
>       usleep_range
> qlcnic_82xx_hw_read_wx_2M (acquire the lock by write_lock_irqsave)
>   crb_win_lock
>     qlcnic_pcie_sem_lock
>       usleep_range
> 
> To fix it, the usleep_range is replaced with udelay.
> 
> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>

Applied.
