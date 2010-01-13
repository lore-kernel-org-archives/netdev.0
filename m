From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] net: at91_ether.c - Allow transmitter interrupt to
 be handled first in ISR
Date: Wed, 13 Jan 2010 19:08:44 +0100
Message-ID: <4B4E0C2C.1000101@gmail.com>
References: <3DBBD805E3BA064A87F551C0E8BD367402897491@MAILSRV.intcomgrp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: James Kosin <JKosin@intcomgrp.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756212Ab0AMSJK@vger.kernel.org>
In-Reply-To: <3DBBD805E3BA064A87F551C0E8BD367402897491@MAILSRV.intcomgrp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 13/01/2010 18:46, James Kosin a =E9crit :
> Ok,
>=20
> This next patch is optional....
>=20
> The idea is TUND should only happen on occasions when the PHY is unab=
le
> to receive the transmitter data in a timely fashion to successfully s=
end
> the data in a single burst.  This is not a hard error; so, why do we
> treat it as such.
>=20
> This patch allows the transmitter to resend the failed skb inside the
> ISR without having to deal with the overhead of freeing the skb then
> having the main task re-allocate a new skb for the failed packet.

Are we sure chip doesnt report TUND forever in some situations ?
Should'nt we have a retry limit for each skb ?

>=20
> James Kosin
>=20
--- C:/Documents and Settings/jkosin/My Documents/junk/kernel/Copy of l=
inux-2.6.31.5/drivers/net/arm/at91_ether.c	Wed Jan 13 12:26:13 2010
+++ C:/Documents and Settings/jkosin/My Documents/junk/kernel/linux-2.6=
=2E31.5/drivers/net/arm/at91_ether.c	Wed Jan 13 12:38:55 2010

Oh well :)

Please read Documentation/SubmittingPatches


1) Should be in "diff -u" form
9) Your patch should be based on latest kernel (preferrably on David ne=
t-next-2.6 git tree)

12) Should be Signed-off-by


You said in a previous mail the chip was capable of queueing two frames=
,
it would be nice to exploit this in driver, since at91 has only one fra=
me
in transmit queue.
