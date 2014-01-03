From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] sh_eth: coding style fixes
Date: Fri, 03 Jan 2014 06:28:59 -0800
Message-ID: <1388759339.14334.10.camel@joe-AO722>
References: <201312310325.21951.sergei.shtylyov@cogentembedded.com>
	 <20140102.193407.23280653408847634.davem@davemloft.net>
	 <1388713347.2259.86.camel@joe-AO722> <52C6886D.2000801@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <52C6886D.2000801@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-01-03 at 13:52 +0400, Sergei Shtylyov wrote:
> On 03-01-2014 5:42, Joe Perches wrote:
> >>> @@ -1952,8 +1949,8 @@ static void sh_eth_tx_timeout(struct net
> >>>   	netif_stop_queue(ndev);
> >>>
> >>>   	if (netif_msg_timer(mdp))
> >>> -		dev_err(&ndev->dev, "%s: transmit timed out, status %8.8x,"
> >>> -	       " resetting...\n", ndev->name, (int)sh_eth_read(ndev, EE=
SR));
> >>> +		dev_err(&ndev->dev, "%s: transmit timed out, status %8.8x, res=
etting...\n"
> >>> +			ndev->name, (int)sh_eth_read(ndev, EESR));
> >>>
> >>>   	/* tx_errors count up */
> >>>   	ndev->stats.tx_errors++;
>=20
> >> You did not build test this.
>=20
> >> drivers/net/ethernet/renesas/sh_eth.c: In function =E2=80=98sh_eth=
_tx_timeout=E2=80=99:
> >> drivers/net/ethernet/renesas/sh_eth.c:1953:4: error: expected =E2=80=
=98)=E2=80=99 before =E2=80=98ndev=E2=80=99
>=20
> > Also, this would likely be better as:
> >
> > 	netif_err(mdp, timer, ndev, "transmit timed out, status %#08lx, re=
setting...\n",
> > 		  sh_eth_read(ndev, EESR));
>=20
>  If checkpoint.pl did point this out, I would have fixed it.

That's not really possible to do via checkpatch.
checkpatch is neither a compiler nor a programmer.

There are _many_ patterns that a person (or maybe
spatch) might spot that checkpatch could not.

checkpatch is a brainless scanner and please use
yours over any advice given by checkpatch.

> Since it doesn't, it's probably material of another patch.

All of the dev_<level> uses in this file/module
should be inspected and possibly converted to
netdev_<level> or netif_<level>.  This could change
and improve the output message logging.

