From: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH
Date: Fri, 3 Sep 2010 23:11:35 +0900
Message-ID: <000601cb4b71$ee6adec0$66f8800a@maildom.okisemi.com>
References: <4C763A67.5040107@dsn.okisemi.com> <4C7D0E7A.5060309@dsn.okisemi.com> <1283266263.2550.106.camel@edumazet-laptop> <000a01cb4a9b$e8d6ab00$66f8800a@maildom.okisemi.com> <1283434847.2454.726.camel@edumazet-laptop> <20100902081007.2f910bc0@nehalam> <000e01cb4b6c$73b4c8d0$66f8800a@maildom.okisemi.com> <1283521416.2453.823.camel@edumazet-laptop>
Cc: "Stephen Hemminger" <shemminger@vyatta.com>,
	"Sam Ravnborg" <sam@ravnborg.org>, "Joe Perches" <joe@perches.com>,
	"LKML" <linux-kernel@vger.kernel.org>,
	"ML netdev" <netdev@vger.kernel.org>,
	"Greg Rose" <gregory.v.rose@intel.com>,
	"Maxime Bizon" <mbizon@freebox.fr>,
	"Kristoffer Glembo" <kristoffer@gaisler.com>,
	"Ralf Baechle" <ralf@linux-mips.org>,
	"John Linn" <john.linn@xilinx.com>,
	"Randy Dunlap" <randy.dunlap@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	"MeeGo" <meego-dev@meego.com>, "Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	"Andrew" <andrew.chih.howe.khor@intel.com>,
	"Intel OTC" <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	"Toshiharu Okada" <okada533@dsn.okisemi.com>,
	"Tomoya Morinaga" <morinaga526@dsn.okisemi.com>,
	"Takahiro Shimizu" <shimizu394@dsn.okisemi.com>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric

Thank you for your information.
I will confirm other drivers.

Thanks, Ohtake(OKISemi)
----- Original Message ----- 
From: "Eric Dumazet" <eric.dumazet@gmail.com>
To: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
Cc: "Stephen Hemminger" <shemminger@vyatta.com>; "Sam Ravnborg" <sam@ravnborg.org>; "Joe Perches" <joe@perches.com>;
"LKML" <linux-kernel@vger.kernel.org>; "ML netdev" <netdev@vger.kernel.org>; "Greg Rose" <gregory.v.rose@intel.com>;
"Maxime Bizon" <mbizon@freebox.fr>; "Kristoffer Glembo" <kristoffer@gaisler.com>; "Ralf Baechle" <ralf@linux-mips.org>;
"John Linn" <john.linn@xilinx.com>; "Randy Dunlap" <randy.dunlap@oracle.com>; "David S. Miller" <davem@davemloft.net>;
"MeeGo" <meego-dev@meego.com>; "Wang, Qi" <qi.wang@intel.com>; "Wang, Yong Y" <yong.y.wang@intel.com>; "Andrew"
<andrew.chih.howe.khor@intel.com>; "Intel OTC" <joel.clark@intel.com>; "Foster, Margie" <margie.foster@intel.com>;
"Toshiharu Okada" <okada533@dsn.okisemi.com>; "Tomoya Morinaga" <morinaga526@dsn.okisemi.com>; "Takahiro Shimizu"
<shimizu394@dsn.okisemi.com>
Sent: Friday, September 03, 2010 10:43 PM
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH


> Le vendredi 03 septembre 2010 a 22:32 +0900, Masayuki Ohtake a ecrit :
> > Hi Eric and Stephen
> >
> > Thank you for your suggestion.
> >
> > I tried modification of "dev->hard_header_len".
> > However, there was no changed to a format of SKB received by kernel.
> >   [Header:14octet] + [payload]
> >
> > So, I can not a single memcpy.
>
> Hmm, maybe you did this at the wrong place ?
>
> Take a look at other drivers how they do this
>
> (network stack default hard_header_len to 14, in net/ethernet/eth.c,
> function ether_setup())
>
>
> find drivers/net | xargs grep -n hard_header_len
>
> Example in drivers/net/wan/hdlc.c
>
> static void hdlc_setup_dev(struct net_device *dev)
> {
>         /* Re-init all variables changed by HDLC protocol drivers,
>          * including ether_setup() called from hdlc_raw_eth.c.
>          */
>         dev->flags               = IFF_POINTOPOINT | IFF_NOARP;
>         dev->priv_flags          = IFF_WAN_HDLC;
>         dev->mtu                 = HDLC_MAX_MTU;
>         dev->type                = ARPHRD_RAWHDLC;
>         dev->hard_header_len     = 16;
>         dev->addr_len            = 0;
>         dev->header_ops          = &hdlc_null_ops;
> }
>
>
>
