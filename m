From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next v2 1/2] hisilicon net: removes the once HANDEL_TX_MSG macro
Date: Mon, 12 Oct 2015 13:59:39 +0200
Message-ID: <6398202.hrOAl1xuJE@wuerfel>
References: <1444620225-2339-1-git-send-email-huangdaode@hisilicon.com> <1444620225-2339-2-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, joe@perches.com, liguozhu@hisilicon.com,
	Yisen.Zhuang@huawei.com, netdev@vger.kernel.org,
	linuxarm@huawei.com, salil.mehta@huawei.com,
	kenneth-lee-2012@foxmail.com, xuwei5@hisilicon.com,
	lisheng011@huawei.com, linux-kernel@vger.kernel.org
To: huangdaode <huangdaode@hisilicon.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444620225-2339-2-git-send-email-huangdaode@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 12 October 2015 11:23:44 huangdaode wrote:
> +                       s += sprintf(s,
> +                                   "\t\ttx_ring on %p:%u,%u,%u,%u,%u,%llu,%llu\n",
> +                                   h->qs[i]->tx_ring.io_base,
> +                                   h->qs[i]->tx_ring.buf_size,
> +                                   h->qs[i]->tx_ring.desc_num,
> +                                   h->qs[i]->tx_ring.max_desc_num_per_pkt,
> +                                   h->qs[i]->tx_ring.max_raw_data_sz_per_desc,
> +                                   h->qs[i]->tx_ring.max_pkt_size,
> +                                   h->qs[i]->tx_ring.stats.sw_err_cnt,
> +                                   h->qs[i]->tx_ring.stats.io_err_cnt);

There is actually a more significant problem with this code, which I
failed to notice when doing the original bugfix: 

You have a sysfs interface here that exports internal data of the
device that should not be visible like this. One problem is that
the io_base is a kernel pointer that must not be visible to non-root
users (so we don't easily create an attack surface for exploits).
Another problem is that the format is not documented in Documentation/ABI/
and that you have multiple values in one sysfs file here.

It would probably be better to completely remove that sysfs interface, and
to use the ethtool netlink interface to export them.

	Arnd
