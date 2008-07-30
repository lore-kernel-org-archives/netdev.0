From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH] typhoon: use request_firmware
Date: Wed, 30 Jul 2008 01:25:11 -0400
Message-ID: <1217395511.31350.6.camel@obelisk.thedillows.org>
References: <1217170232.3537.6.camel@jaswinder.satnam>
	 <1217209400.22789.47.camel@obelisk.thedillows.org>
	 <1217215009.2970.7.camel@jaswinder.satnam>
	 <1217248585.22789.58.camel@obelisk.thedillows.org>
	 <1217253260.17632.6.camel@jaswinder.satnam>
	 <1217295498.28682.16.camel@obelisk.thedillows.org>
	 <1217347786.2885.11.camel@jaswinder.satnam>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>, becker@scyld.com,
	davidpmclean@yahoo.com, Jeff Garzik <jeff@garzik.org>,
	netdev <netdev@vger.kernel.org>,
	David Woodhouse <dwmw2@infradead.org>
To: Jaswinder Singh <jaswinder@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.knology.net ([24.214.63.101]:48332 "EHLO smtp.knology.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751502AbYG3FZQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2008 01:25:16 -0400
In-Reply-To: <1217347786.2885.11.camel@jaswinder.satnam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-07-29 at 21:39 +0530, Jaswinder Singh wrote:
> On Mon, 2008-07-28 at 21:38 -0400, David Dillow wrote:
> > This should move to either typhoon_init() or typhoon_init_one(). Pu=
tting
> > it in typhoon_init() means we waste memory when the module is loade=
d if
> > there is no typhoon NIC; putting it in typhoon_init_one() means it =
needs
> > protection from threaded probing, should that ever be put back in. =
Given
> > that most modern distros don't do probing by blinding loading modul=
es,
> > typhoon_init() seems a safe bet.
> >=20
>=20
> Sorry Dave, I need tp->pdev so =EF=BB=BFtyphoon_init_one() seems bett=
er.
> I hope you do not mind this.

That's fine, and makes sense. However, you need to check if you've
already loaded it (typhoon_fw !=3D NULL), so you don't leak memory if
there is more than one NIC. Part of me feels like there should be a
mutex around loading the firmware, to avoid surprises if PCI probing
gets multi-threaded again, but a comment to that effect may suffice for
now.

Also, if not adding a mutex, then this can be folded into
typhoon_init_one(), rather than living in a separate function.=20

All in all, this is getting better, my reservations about the goal
aside.

Dave

