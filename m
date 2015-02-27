From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [RFC][PATCH] usbnet: Fix tx_bytes statistic running backward in
 cdc_ncm
Date: Fri, 27 Feb 2015 10:17:59 +0100
Message-ID: <1425028679.12236.6.camel@linux-0dmf.site>
References: <1424979823.4444.46.camel@xylophone.i.decadent.org.uk>
	 <87h9u73eh0.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <ben.hutchings@codethink.co.uk>,
	netdev@vger.kernel.org,
	ct-linux-kernel <linux-kernel@codethink.co.uk>,
	linux-usb@vger.kernel.org, Sami Farin <hvtaifwkbgefbaei@gmail.com>,
	Aleksander Morgado <aleksander@aleksander.es>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:57018 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752382AbbB0JaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 04:30:03 -0500
In-Reply-To: <87h9u73eh0.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-02-27 at 10:12 +0100, Bj=C3=B8rn Mork wrote:
> Ben Hutchings <ben.hutchings@codethink.co.uk> writes:
>=20
> > cdc_ncm disagrees with usbnet about how much framing overhead shoul=
d
> > be counted in the tx_bytes statistics, and tries 'fix' this by
> > decrementing tx_bytes on the transmit path.  But statistics must ne=
ver
> > be decremented except due to roll-over; this will thoroughly confus=
e
> > user-space.  Also, tx_bytes is only incremented by usbnet in the
> > completion path.
> >
> > Fix this by requiring drivers that set FLAG_MULTI_FRAME to set a
> > tx_bytes delta along with the tx_packets count.
> >
> > Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
> > ---
> > I noticed this bug while trying to fix the tx_packets statistic in =
asix.
> > It depends on the patch I just sent for that.  I don't have any har=
dware
> > to test this with, or any need to make it work.  If you want this f=
ix,
> > please test and re-submit it yoursef.
>=20
> I tested this on an MBIM device, and it worked perfectly as-is.  Plea=
se
> submit it without the RFC prefix.  This fixes a real and reported
> problem with the cdc_ncm driver, so I'd claim it's "net" material alo=
ng
> with a stable Cc and
>=20
> Fixes: beeecd42c3b4 ("net: cdc_ncm/cdc_mbim: adding NCM protocol stat=
istics")
>=20
> But you and David decide that, of course...
>=20
>=20
> Fixing this was actually on my TODO-list after a recent report showin=
g
> one of the problems with the previous hack: The decremented tx_bytes
> counter was never corrected if the URB transmission failed, possibly
> ending up with a negative (i.e. very large since it is unsigned)
> tx_bytes counter.
>=20
> Thanks a lot.  I didn't know how to do this without introducing a new
> callback or something.  Your solutions is very nice, and so obvious w=
hen
> I see it.  Just brilliant :-)
>=20
> Tested-by: Bj=C3=B8rn Mork <bjorn@mork.no>
>=20
> And you might also want (if this is OK for Sami):
>=20
> Reported-by: Sami Farin <hvtaifwkbgefbaei@gmail.com>
Acked-by: Oliver Neukum <oliver@neukum.org>
