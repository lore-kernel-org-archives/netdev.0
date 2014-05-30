From: "ezequiel.garcia@free-electrons.com"
	<ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH v1 4/6] net: fec: Increase buffer descriptor entry number
Date: Fri, 30 May 2014 13:35:15 -0300
Message-ID: <20140530163515.GA10354@arch.cereza>
References: <1401415552-2263-1-git-send-email-b38611@freescale.com>
 <1401415552-2263-5-git-send-email-b38611@freescale.com>
 <063D6719AE5E284EB5DD2968C1650D6D1725053E@AcuExch.aculab.com>
 <bf938381e86b4ef5b4e3cbec8733fd2e@BLUPR03MB373.namprd03.prod.outlook.com>
 <1401455586.3645.96.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140530140137.GC783@arch.cereza>
 <1401461642.3645.104.camel@edumazet-glaptop2.roam.corp.google.com>
 <417d6b6ae192430f9fee0a339074d9c6@BLUPR03MB373.namprd03.prod.outlook.com>
 <063D6719AE5E284EB5DD2968C1650D6D17250953@AcuExch.aculab.com>
 <1401465492.3645.122.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Laight <David.Laight@ACULAB.COM>,
	"'fugang.duan@freescale.com'" <fugang.duan@freescale.com>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:58368 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752015AbaE3Qf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 12:35:58 -0400
Content-Disposition: inline
In-Reply-To: <1401465492.3645.122.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30 May 08:58 AM, Eric Dumazet wrote:
> On Fri, 2014-05-30 at 15:34 +0000, David Laight wrote:
>=20
> > Software TSO generates lots of separate ethernet frames, there is n=
o
> > absolute requirement to be able to put all of them into the tx ring=
 at once.
>=20
> Yes there is absolute requirement. It is driver responsibility to blo=
ck
> the queue if the available slots in TX ring would not allow the
> following packet to be sent.
>=20
> Thats why a TSO emulation needs to set gso_max_segs to some sane valu=
e
>=20
> (sfc sets it to 100)
>=20
> In Fugang patch this part was a wrong way to deal with this :
>=20
> +       if (tso_count_descs(skb) >=3D fec_enet_txdesc_entry_free(fep)=
) {
> +               if (net_ratelimit())
> +                       netdev_err(ndev, "tx queue full!\n");
> +               return NETDEV_TX_BUSY;
> +       }
> +
>=20
> This was copy/pasted from buggy
> drivers/net/ethernet/marvell/mv643xx_eth.c
>=20

Indeed. I'm just about to submit the fixes for those, which may be usef=
ul to
fix it in this driver as well.
--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
