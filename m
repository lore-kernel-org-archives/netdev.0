From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: Latest PreemptRT patch error on imx35
Date: Mon, 31 Aug 2009 15:22:00 +0200
Message-ID: <20090831132200.GA21836@pengutronix.de>
References: <200908311143.08952.tim01@vlsi.informatik.tu-darmstadt.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-rt-users <linux-rt-users@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Greg Ungerer <gerg@uclinux.org>, netdev@vger.kernel.org
To: Tim Sander <tim01@vlsi.informatik.tu-darmstadt.de>
Return-path: <linux-rt-users-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200908311143.08952.tim01@vlsi.informatik.tu-darmstadt.de>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Tim,

> I just bootet 2.6.31-rc8-rt9 on the phycore-imx35 development board,=20
> without any additional patches. The FEC Ethernet Controller went bell=
y=20
> up, but the system booted nevertheless. [...]
The problem is that &fep->mii_lock is taken twice.  On a normal (i.e.
non-RT) UP system that doesn't hurt because spinlocks are noops (unless
you have some debugging code activated).

The exact problem is:
	fec_enet_mii (this takes &fep->mii_lock) and calls mip->mii_func
	which happens to be mii_queue.  mii_queue in turn takes
	&fep->mii_lock again.

The correct fix is probably to split mii_queue into a function that
locks and a function that does the actual work.  And then use the latte=
r
in fec_enet_mii.

I'd prepare a patch but my wife just called me to eat some cake :-)

So maybe later today or tomorrow, we'll see.

Best regards
Uwe

--=20
Pengutronix e.K.                              | Uwe Kleine-K=F6nig     =
       |
Industrial Linux Solutions                    | http://www.pengutronix.=
de/  |
--
To unsubscribe from this list: send the line "unsubscribe linux-rt-user=
s" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
