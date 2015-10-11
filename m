From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] BNX2: fix a Null Pointer for stats_blk
Date: Sun, 11 Oct 2015 05:07:01 -0700 (PDT)
Message-ID: <20151011.050701.821276159987364704.davem@davemloft.net>
References: <560A02FA.6030309@huawei.com>
	<20150929.211011.677113057504126372.davem@davemloft.net>
	<56163F83.1000901@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sony.chacko@qlogic.com, Dept-HSGLinuxNICDev@qlogic.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rui.xiang@huawei.com, manish.chopra@qlogic.com
To: wangweidong1@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56163F83.1000901@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Weidong Wang <wangweidong1@huawei.com>
Date: Thu, 8 Oct 2015 18:03:47 +0800

> we have two processes to do:
> P1#: ifconfig eth0 down; which will call bnx2_close, then will
> , and set Null to stats_blk
> P2#: ifconfig eth0; which will call bnx2_get_stats64, it will
> use stats_blk.
> In one case:
>     --P1#--                   --P2#--
>                               stats_blk(no null)
>     bnx2_free_mem
>     ->bp->stats_blk = NULL
>                               GET_64BIT_NET_STATS
> 
> then it will cause 'NULL Pointer' Problem.
> it is as well with 'ethtool -S ethx'.
> 
> Allocate the statistics block at probe time so that this problem is
> impossible
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>

Applied, thank you.
