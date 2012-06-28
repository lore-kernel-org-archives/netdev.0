From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH net] net: qmi_wwan: fix Oops while disconnecting
Date: Thu, 28 Jun 2012 10:35:19 +0200
Message-ID: <201206281035.19964.oneukum@suse.de>
References: <1340356279-3124-1-git-send-email-bjorn@mork.no> <201206251410.13454.oliver@neukum.org> <CACVXFVO5x9pePZekJPnywr7czXG_3_xCRj-rXEgf2KSQXnmPbA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?iso-8859-1?q?Bj=F8rn_Mork?= <bjorn@mork.no>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Marius =?iso-8859-1?q?Bj=F8rnstad_Kotsbak?=
	<marius.kotsbak@gmail.com>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:51129 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756223Ab2F1IfN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 04:35:13 -0400
In-Reply-To: <CACVXFVO5x9pePZekJPnywr7czXG_3_xCRj-rXEgf2KSQXnmPbA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag, 26. Juni 2012, 09:23:19 schrieb Ming Lei:
> On Mon, Jun 25, 2012 at 8:10 PM, Oliver Neukum <oliver@neukum.org> wr=
ote:

> > At this point a minidriver must not follow the intfdata pointer,
> > because the interface may again be probed. So if here a minidriver
>=20
> IMO, probe is serialized strictly with driver unbind since both the p=
arent
> lock and its own device lock have been held, so the probe may only be
> started after driver unbinding is completed.

Yes, but if you have a driver which claims multiple interfaces and uses
a subdriver, then you will have cases of intfdate being NULL before
disconnect() finishes.

> > still uses intfdata, locking will be needed. We want to catch those
> > casees.
>=20
> Suppose infdata is used here somewhere, it is surely a bug because
> the usbnet instance pointed by intfdata will be freed soon.

Of course. That is the point.

> So looks putting the set to NULL after driver_info->unbind is good,
> doesn't it?

Again, of course. We could drop it (but not the check for NULL in usbne=
t).
It is a debugging aid.=20

> >        usb_kill_urb(dev->interrupt);
> >        usb_free_urb(dev->interrupt);
> >
> >        free_netdev(net);
> >        usb_put_dev (xdev);
> > }
> >
> >> > Sure, it is a debugging aid. It has the drawback that minidriver=
s have
> >> > to be able to deal with intfdata being NULL. That is not hard to=
 do.
> >>
> >> The check isn't needed if the set to NULL is put after  driver_inf=
o->unbind
> >> in usbnet_disconnect.
> >
> > True, but we don't catch bugs.
>=20
> If the check is added, the bugs may be hided, and no stack will be
> dumped, :-)

That is also true.

Bj=F8rn,

do you use subdrivers with cdc-ether?

	Regards
		Oliver

--=20
- - -=20
SUSE LINUX Products GmbH, GF: Jeff Hawn, Jennifer Guild, Felix Imend=F6=
rffer, HRB 16746 (AG N=FCrnberg)=20
Maxfeldstra=DFe 5                        =20
90409 N=FCrnberg=20
Germany=20
- - -=20
