From: Manoil Claudiu <claudiu.manoil@freescale.com>
Subject: RE: [PATCH] gianfar: Fix warnings when built on 64-bit
Date: Wed, 29 Jul 2015 08:41:29 +0000
Message-ID: <BY2PR0301MB072721F7AD52766A864FC79E9C8C0@BY2PR0301MB0727.namprd03.prod.outlook.com>
References: <1438147477-393-1-git-send-email-scottwood@freescale.com>
 <4498062.4y369pLSmO@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Arnd Bergmann <arnd@arndb.de>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0147.outbound.protection.outlook.com ([207.46.100.147]:19958
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751462AbbG2Ila convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 04:41:30 -0400
In-Reply-To: <4498062.4y369pLSmO@wuerfel>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Arnd Bergmann [mailto:arnd@arndb.de]
> Sent: Wednesday, July 29, 2015 11:02 AM
> To: linuxppc-dev@lists.ozlabs.org; netdev@vger.kernel.org; Manoil Claudiu-
> B08782; Wood Scott-B07421
> Subject: Re: [PATCH] gianfar: Fix warnings when built on 64-bit
> 
> On Wednesday 29 July 2015 00:24:37 Scott Wood wrote:
> 
> > Alternatively, if there's a desire to not mess with this code (I don't
> > know how to trigger this code path to test it), this driver should be
> > given dependencies that ensure that it only builds on 32-bit.
> 
> These are obvious fixes, they should definitely go in.

This patch conflicts with the rx s/g patch series:
https://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/?id=9061cb023567abf081569d6851b0815dd18437e6

So if applied as it is on top of net.git it will give a headache when net-next.git
will be merged into net.git (or vice versa).

Since there are no 64-bit systems with gianfar/ eTSEC, I think that this patch
should target net-next.git (reworked to be applicable on net-next.git) to avoid
the conflict.   I could do this rework and resend it on top of net-next.git

> 
> >  drivers/net/ethernet/freescale/gianfar.c | 22 ++++++++++++++++++----
> >  1 file changed, 18 insertions(+), 4 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/freescale/gianfar.c
> b/drivers/net/ethernet/freescale/gianfar.c
> > index ff87502..7c682ac 100644
> > --- a/drivers/net/ethernet/freescale/gianfar.c
> > +++ b/drivers/net/ethernet/freescale/gianfar.c
> > @@ -565,6 +565,7 @@ static void gfar_ints_enable(struct gfar_private
> *priv)
> >  	}
> >  }
> >
> > +#ifdef CONFIG_PM
> >  static void lock_tx_qs(struct gfar_private *priv)
> >  {
> >  	int i;
> > @@ -580,6 +581,7 @@ static void unlock_tx_qs(struct gfar_private *priv)
> >  	for (i = 0; i < priv->num_tx_queues; i++)
> >  		spin_unlock(&priv->tx_queue[i]->txlock);
> >  }
> > +#endif
> >
> 
> This seems unrelated and should probably be a separate fix.
> 

I'm working at a patch set to revive/ cleanup the power management code,
and lock_tx_qs() is planned to be removed (it can be shown that it's not needed).
So this change can be remove from this patch.

Thanks,
Claudiu

[...]
