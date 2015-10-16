From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] net: hix5hd2_gmac: avoid integer overload warning
Date: Fri, 16 Oct 2015 13:28:04 +0200
Message-ID: <9667302.4m5v3ViVSt@wuerfel>
References: <1444967657-107994-1-git-send-email-huangdaode@hisilicon.com> <4752736.dePgPCNd9q@wuerfel> <063D6719AE5E284EB5DD2968C1650D6D1CBB97A6@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: huangdaode <huangdaode@hisilicon.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"joe@perches.com" <joe@perches.com>,
	"liguozhu@hisilicon.com" <liguozhu@hisilicon.com>,
	"Yisen.Zhuang@huawei.com" <Yisen.Zhuang@huawei.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxarm@huawei.com" <linuxarm@huawei.com>,
	"salil.mehta@huawei.com" <salil.mehta@huawei.com>,
	"kenneth-lee-2012@foxmail.com" <kenneth-lee-2012@foxmail.com>,
	"xuwei5@hisilicon.com" <xuwei5@hisilicon.com>,
	"lisheng011@huawei.com" <lisheng011@huawei.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"lipeng321@huawei.com" <lipeng321@huawei.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CBB97A6@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 16 October 2015 11:14:44 David Laight wrote:
> From: Arnd Bergmann
> > Sent: 16 October 2015 11:01
> > BITS_RX_EN is an 'unsigned long' constant, so the ones complement of that
> > has bits set that do not fit into a 32-bit variable on 64-bit architectures,
> > which causes a harmless gcc warning:
> ...
> >  static void hix5hd2_port_disable(struct hix5hd2_priv *priv)
> >  {
> > -     writel_relaxed(~(BITS_RX_EN | BITS_TX_EN), priv->base + PORT_EN);
> > +     writel_relaxed(~(u32)(BITS_RX_EN | BITS_TX_EN), priv->base + PORT_EN);
> >       writel_relaxed(0, priv->base + DESC_WR_RD_ENA);
> 
> ISTM that just means that the constants shouldn't be 'long'.

Right, but that would probably mean changing the BIT() macro or not using it
here. In the past I've argued against using that macro, but I've given
up that fight.

	Arnd
