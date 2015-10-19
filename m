From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: hix5hd2_gmac: avoid integer overload warning
Date: Sun, 18 Oct 2015 20:01:45 -0700 (PDT)
Message-ID: <20151018.200145.258165069418211324.davem@davemloft.net>
References: <1444967657-107994-1-git-send-email-huangdaode@hisilicon.com>
	<4752736.dePgPCNd9q@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: huangdaode@hisilicon.com, joe@perches.com, liguozhu@hisilicon.com,
	Yisen.Zhuang@huawei.com, netdev@vger.kernel.org,
	linuxarm@huawei.com, salil.mehta@huawei.com,
	kenneth-lee-2012@foxmail.com, xuwei5@hisilicon.com,
	lisheng011@huawei.com, linux-kernel@vger.kernel.org,
	lipeng321@huawei.com
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4752736.dePgPCNd9q@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 16 Oct 2015 12:00:51 +0200

> BITS_RX_EN is an 'unsigned long' constant, so the ones complement of that
> has bits set that do not fit into a 32-bit variable on 64-bit architectures,
> which causes a harmless gcc warning:
> 
> drivers/net/ethernet/hisilicon/hix5hd2_gmac.c: In function 'hix5hd2_port_disable':
> drivers/net/ethernet/hisilicon/hix5hd2_gmac.c:374:2: warning: large integer implicitly truncated to unsigned type [-Woverflow]
>   writel_relaxed(~(BITS_RX_EN | BITS_TX_EN), priv->base + PORT_EN);
> 
> This adds a cast to (u32) to tell gcc that the code is indeed fine.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
