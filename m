From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/3] net: hns: Add TX CSUM check when fill TX
 description
Date: Tue, 04 Jul 2017 03:28:33 -0700 (PDT)
Message-ID: <20170704.032833.2030036660842556798.davem@davemloft.net>
References: <1499165253-184543-1-git-send-email-linyunsheng@huawei.com>
        <1499165253-184543-2-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: huangdaode@hisilicon.com, xuwei5@hisilicon.com,
        liguozhu@hisilicon.com, Yisen.Zhuang@huawei.com,
        gabriele.paoloni@huawei.com, john.garry@huawei.com,
        linuxarm@huawei.com, salil.mehta@huawei.com, lipeng321@huawei.com,
        tremyfr@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: linyunsheng@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1499165253-184543-2-git-send-email-linyunsheng@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lin Yun Sheng <linyunsheng@huawei.com>
Date: Tue, 4 Jul 2017 18:47:31 +0800

> From: Yunsheng Lin <linyunsheng@huawei.com>
> 
> If driver support checksum offload, should check netdev feature
> before fill TX description and get CSUM err bit from RX
> description. HNS driver do the check in RX derction but it doesn't
> do the check in TX direction.
> 
> Signed-off-by: lipeng <lipeng321@huawei.com>
> Reviewed-by: Daode Huang <huangdaode@hisilicon.com>
> Reviewed-by: Yunsheng Lin <linyunsheng@huawei.com>

This is not correct.

You should be checking the skb->checksum field to decide if you should
offload the TX checksum of the packet or not.

Correct drivers, as far as I am aware, do not check the feature flags
so I wonder where you got this idea from.  Always use other well
established existing drivers as a model for how to handle things like
this.

And this makes sense.  An SKB can have it's checksumming determination
made first, then the netdev feature change is made afterwards.  For
correctness you still need to TX checksum offload that SKB otherwise
it will be emitted without a correctly computed checksum.

Thank you.
