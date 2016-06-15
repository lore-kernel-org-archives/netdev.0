From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] net: hns: add skb_reset_mac_header() after
 skb being alloc
Date: Tue, 14 Jun 2016 22:41:34 -0700 (PDT)
Message-ID: <20160614.224134.743787632695474309.davem@davemloft.net>
References: <1465821682-223053-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, charles.chenxin@huawei.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linuxarm@huawei.com
To: Yisen.Zhuang@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465821682-223053-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Date: Mon, 13 Jun 2016 20:41:22 +0800

> From: Kejian Yan <yankejian@huawei.com>
> 
> HNS receives a packet without doing anything, but it should call
> skb_reset_mac_header() to initialize the header before using
> eth_hdr().
> 
> Fixes: 0d6b425a3773c3445b0f51b2f333821beaacb619
> Signed-off-by: Kejian Yan <yankejian@huawei.com>
> Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>

Well, this patch made me look at this function.

You really shouldn't be filtering packets looped back, that is
the stack's job.  It shouldn't be happening in the driver.

And once you remove that code, this patch here is no longer
necessary.

Second of all, unless you card supports every protocol that
exists in the past, present, and _future_ you cannot set
skb->ip_summed to CHECKSUM_UNNECSSARY unconditionally like
that.

You can only set that for protocols your chip actually supports.
