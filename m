From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] drivers: misc: Remove MISC_DEVICES config option
Date: Fri, 6 Jan 2012 12:00:43 +0000
Message-ID: <201201061200.44183.arnd@arndb.de>
References: <1325796541-11402-1-git-send-email-festevam@gmail.com> <CAOMZO5BQhcxViN3KnjhzF9hL1w04egkmb9njc7sDUB0GFdgBog@mail.gmail.com> <20120106050355.GA7633@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fabio Estevam <festevam@gmail.com>, netdev@vger.kernel.org,
	gwingerde@gmail.com, larry.finger@lwfinger.net,
	davem@davemloft.net, bhutchings@solarflare.com,
	linux-kernel@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:64398 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933140Ab2AFMA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2012 07:00:56 -0500
In-Reply-To: <20120106050355.GA7633@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 06 January 2012, Greg KH wrote:
> On Thu, Jan 05, 2012 at 11:18:28PM -0200, Fabio Estevam wrote:
> > On Thu, Jan 5, 2012 at 8:39 PM, Greg KH <greg@kroah.com> wrote:
> >=20
> > > Are you sure that this isn't getting confused with the
> > > drivers/char/misc.c interface instead of the "throw a bunch of ra=
ndome
> > > drivers into drivers/misc/" issue?
> >=20
> > Sorry, I am not aware of this issue.
> >=20
> > > Why would anything ever want to select MISC_DEVICES?  What happen=
s if
> > > you just remove that select line from the Kconfig?
> >=20
> > Yes, I don=B4t understand the point of allowing the selection MISC_=
DEVICES.
> >=20
> > IMHO it is potential for causing dependency issues.
>=20
> Then remove that selection.  Nothing should be depending on a misc
> driver, if it is, then that implies that this is more than just a "mi=
sc"
> driver, and it should be moved elsewhere.

I think that is true for the majority of stuff we have under drivers/mi=
sc
anyway. I had done the same patch that Fabio sent a couple of months ag=
o
but then forgot about it, so here is a wholehearted

Acked-by: Arnd Bergmann <arnd@arndb.de>

for the new patch. It fixes a real problem, and we applied a similar pa=
tch
in drivers/mfd as 8a0a8e8e already. We probably still want to find a be=
tter
home for drivers that frequently get selected by other subsystems as yo=
u
said, but that is an independent issue. I don't see why anyone would
need a way to disable all MISC drivers at once, when the only thing tha=
t
(in theory) connects them is that they are all different from everythin=
g
else.

	Arnd
