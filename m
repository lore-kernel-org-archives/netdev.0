From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [PATCH] net: calxedaxgmac: fix driver dependencies
Date: Tue, 02 Sep 2014 11:51:34 +0200
Message-ID: <10071967.pgEgsHtCJd@amdc1032>
References: <7268934.nBXHizFkl4@amdc1032>
 <CAL_JsqJV0rJ_PCLBsZNYdYdbER7UR_MV40BGjpykh7uubLh__g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Kyungmin Park <kyungmin.park@samsung.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Rob Herring <robh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:11717 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751503AbaIBJvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 05:51:41 -0400
In-reply-to: <CAL_JsqJV0rJ_PCLBsZNYdYdbER7UR_MV40BGjpykh7uubLh__g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

On Monday, September 01, 2014 09:36:39 PM Rob Herring wrote:
> On Mon, Sep 1, 2014 at 10:39 AM, Bartlomiej Zolnierkiewicz
> <b.zolnierkie@samsung.com> wrote:
> > Calxeda 1G/10G XGMAC Ethernet support should be available only on
> > Calxeda ECX-1000/2000 (Highbank/Midway) platforms.
> >
> > Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> > Acked-by: Kyungmin Park <kyungmin.park@samsung.com>
> > Cc: Rob Herring <robh@kernel.org>
> > ---
> >  drivers/net/ethernet/calxeda/Kconfig |    1 +
> >  1 file changed, 1 insertion(+)
> >
> > Index: b/drivers/net/ethernet/calxeda/Kconfig
> > ===================================================================
> > --- a/drivers/net/ethernet/calxeda/Kconfig      2014-07-30 14:31:12.159522474 +0200
> > +++ b/drivers/net/ethernet/calxeda/Kconfig      2014-09-01 17:33:49.232810483 +0200
> > @@ -1,6 +1,7 @@
> >  config NET_CALXEDA_XGMAC
> >         tristate "Calxeda 1G/10G XGMAC Ethernet driver"
> >         depends on HAS_IOMEM && HAS_DMA
> > +       depends on ARCH_HIGHBANK || COMPILE_TEST
> 
> Opinions differ on whether drivers should be restricted in this way.
> There is no actual dependency requiring ARCH_HIGHBANK. So I leave it
> to David.

The hardware is specific to ARCH_HIGHBANK and it is just unavailble on
any other platform (i.e. I have completely no use for this option on
ARM Exynos platform).  In such cases we restrict drivers to the specific
hardware platform so they don't pollute configs for other platforms
(i.e. this option is enabled by default in multi_v7_defconfig and once
I go from multi defconfing to single platform one, the option stays
enabled).

Best regards,
--
Bartlomiej Zolnierkiewicz
Samsung R&D Institute Poland
Samsung Electronics
