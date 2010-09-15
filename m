From: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH
Date: Wed, 15 Sep 2010 21:19:36 +0900
Message-ID: <001601cb54d3$3aceb8d0$66f8800a@maildom.okisemi.com>
References: <4C81019E.1010808@dsn.okisemi.com><4C85A6AD.9080301@dsn.okisemi.com> <20100908.133627.70178420.davem@davemloft.net>
Cc: <randy.dunlap@oracle.com>, <ralf@linux-mips.org>,
	<eric.dumazet@gmail.com>, "ML netdev" <netdev@vger.kernel.org>,
	<meego-dev@meego.com>, <mbizon@freebox.fr>,
	"ML linux-kernel" <linux-kernel@vger.kernel.org>,
	<kristoffer@gaisler.com>, <john.linn@xilinx.com>,
	<joe@perches.com>, <gregory.v.rose@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	"Wang, Qi" <qi.wang@intel.com>, "okada" <okada533@dsn.okisemi.com>,
	"Morinaga" <morinaga526@dsn.okisemi.com>,
	"shimizu" <shimizu394@dsn.okisemi.com>,
	"Intel OTC" <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	<andrew.chih.howe.khor@intel.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:25189 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752681Ab0IOMkw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 08:40:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

Thank you for your comments.
I will modify like your comment and resubmit patch.

Thanks Ohtake
-----
Date: Wed, 08 Sep 2010 13:36:27 -0700 (PDT)
From: "David Miller" <davem@davemloft.net>
> > +/**
> > + * pch_gbe_clean_rx - Send received data up the network stack; legacy
> > + * @adapter:     Board private structure
> > + * @rx_ring:     Rx descriptor ring
> > + * @work_done:   Completed count
> > + * @work_to_do:  Request count
> > + * Returns
> > + * true:  Cleaned the descriptor
> > + * false: Not cleaned the descriptor
> > + */
> > +static bool
> > +pch_gbe_clean_rx(struct pch_gbe_adapter *adapter,
> > + struct pch_gbe_rx_ring *rx_ring,
> > + int *work_done, int work_to_do)
> > +{
> ..
> > + if (netif_receive_skb(skb) == NET_RX_DROP) {
> > + adapter->stats.rx_dropped++;
>
> pch_gbe_clean_rx() should be given the "napi_struct" pointer
> argument from it's caller, and packets should be given to the
> stack using napi_gro_receive().  Finally, NETIF_F_GRO should
> be set in netdev->flags at probe time.
>
> Also, you should not use the return value of netif_receive_skb() to
> bump the standard rx_dropped statistics value, those return code are
> for other purposes.  No other driver does what you are doing with this
> return value.
>
> If you wish to increment some extended stastic value (like
> drivers/net/gianfar.c does) with another name, that's fine.
>



