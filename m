From: Jamie Iles <jamie@jamieiles.com>
Subject: Re: [PATCH v3 08/10] ARM: mxs: add ocotp read function
Date: Wed, 5 Jan 2011 17:25:01 +0000
Message-ID: <20110105172501.GB2112@gallagher>
References: <1294236457-17476-1-git-send-email-shawn.guo@freescale.com>
 <1294236457-17476-9-git-send-email-shawn.guo@freescale.com>
 <20110105161235.GA2112@gallagher>
 <20110105164409.GV25121@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamie Iles <jamie@jamieiles.com>,
	Shawn Guo <shawn.guo@freescale.com>, gerg@snapgear.com,
	B32542@freescale.com, netdev@vger.kernel.org,
	s.hauer@pengutronix.de, baruch@tkos.co.il, w.sang@pengutronix.de,
	r64343@freescale.com, eric@eukrea.com, bryan.wu@canonical.com,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	lw@karo-electronics.de
To: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:48926 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751357Ab1AERZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 12:25:08 -0500
Received: by wwa36 with SMTP id 36so16529639wwa.1
        for <netdev@vger.kernel.org>; Wed, 05 Jan 2011 09:25:06 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20110105164409.GV25121@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 05, 2011 at 05:44:09PM +0100, Uwe Kleine-K=F6nig wrote:
> Hello Jamie,
> On Wed, Jan 05, 2011 at 04:16:46PM +0000, Jamie Iles wrote:
> > On Wed, Jan 05, 2011 at 10:07:35PM +0800, Shawn Guo wrote:
> > > +	/* check both BUSY and ERROR cleared */
> > > +	while ((__raw_readl(ocotp_base) &
> > > +		(BM_OCOTP_CTRL_BUSY | BM_OCOTP_CTRL_ERROR)) && --timeout)
> > > +		/* nothing */;
> >=20
> > Is it worth using cpu_relax() in these polling loops?
> I don't know what cpu_relax does for other platforms, but on ARM it's
> just a memory barrier which AFAICT doesn't help here at all (which
> doesn't need to be correct).  Why do you think it would be better?

Well I don't see that there's anything broken without cpu_relax() but=20
using cpu_relax() seems to be the most common way of doing busy polling=
=20
loops that I've seen. It's also a bit easier to read than a comment and=
=20
semi-colon. Perhaps it's just personal preference.

Jamie
