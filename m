From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v2 1/2] hisilicon net: removes the once
 HANDEL_TX_MSG macro
Date: Mon, 12 Oct 2015 09:12:54 -0700
Message-ID: <1444666374.9184.1.camel@perches.com>
References: <1444620225-2339-1-git-send-email-huangdaode@hisilicon.com>
	 <1444620225-2339-2-git-send-email-huangdaode@hisilicon.com>
	 <6398202.hrOAl1xuJE@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: huangdaode <huangdaode@hisilicon.com>, davem@davemloft.net,
	liguozhu@hisilicon.com, Yisen.Zhuang@huawei.com,
	netdev@vger.kernel.org, linuxarm@huawei.com,
	salil.mehta@huawei.com, kenneth-lee-2012@foxmail.com,
	xuwei5@hisilicon.com, lisheng011@huawei.com,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6398202.hrOAl1xuJE@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-10-12 at 13:59 +0200, Arnd Bergmann wrote:
> On Monday 12 October 2015 11:23:44 huangdaode wrote:
> > +                       s += sprintf(s,
> > +                                   "\t\ttx_ring on %p:%u,%u,%u,%u,%u,%llu,%llu\n",
> > +                                   h->qs[i]->tx_ring.io_base,
[]
> There is actually a more significant problem with this code, which I
> failed to notice when doing the original bugfix: 
> 
> You have a sysfs interface here that exports internal data of the
> device that should not be visible like this. One problem is that
> the io_base is a kernel pointer that must not be visible to non-root
> users (so we don't easily create an attack surface for exploits).

Using %pK might have been appropriate.

> It would probably be better to completely remove that sysfs interface, and
> to use the ethtool netlink interface to export them.

But this would be better.
