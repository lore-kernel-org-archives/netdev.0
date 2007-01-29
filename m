From: Bernhard Walle <bwalle@suse.de>
Subject: Re: r8169: Crash after reloading driver if network hangs
Date: Mon, 29 Jan 2007 11:25:03 +0100
Message-ID: <20070129102503.GA30182@strauss.suse.de>
References: <20070128180221.GB2285@strauss.suse.de> <20070128190448.GA23060@electric-eye.fr.zoreil.com> <20070128195656.GA6013@strauss.suse.de> <20070129075606.GA10598@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:49119 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752494AbXA2KZG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jan 2007 05:25:06 -0500
Content-Disposition: inline
In-Reply-To: <20070129075606.GA10598@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

* Francois Romieu <romieu@fr.zoreil.com> [2007-01-29 08:56]:
> Bernhard Walle <bwalle@suse.de> :
>=20
> > @@ -1371,10 +1371,9 @@ static inline void rtl8169_request_timer
> >                 return;
> > =20
> >         init_timer(timer);
> > -       timer->expires =3D jiffies + RTL8169_PHY_TIMEOUT;
> >         timer->data =3D (unsigned long)(dev);
> >         timer->function =3D rtl8169_phy_timer;
> > -       add_timer(timer);
> > +       mod_timer(timer, jiffies + RTL8169_PHY_TIMEOUT);
> >  }
> >=20
> > But I think _this_ change is unnecessary, ...
>=20
> add_timer() is not supposed to modify an existing timer whereas mod_t=
imer()
> encompasses both=20

that's clear.

> and the race exists in both direction as netif_running()
> is true as soon as dev_open() starts but way before dev->open() compl=
etes.

But rtl8169_request_timer() is only called from change_mtu() and
dev->open(). And, if you call init_timer(), you always have a new
timer, and the reference to an existing tp->timer will be lost.

> [...]
> > ... but that looks good (better than my patch) and should resolve t=
he issue,
> > too. I can't test because it's triggered only if the network hangs =
and you
> > know, the last one isn't reproducable.
>=20
> There will be something to test in the merge of realtek's stuff #2.

Great.


Regards,
Bernhard
--=20
SUSE LINUX Products GmbH                E-Mail:  bwalle@suse.de
Maxfeldstr. 5                           Phone:   +49 (911) 74053-0
90409 N=FCrnberg, Germany
OpenPGP DDAF6454: F61F 34CC 09CA FB82 C9F6  BA4B 8865 3696 DDAF 6454
