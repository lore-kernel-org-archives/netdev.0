From: Greg KH <greg@kroah.com>
Subject: Re: 3.0.8 kernel : NULL ptr deref in skb_queue_purge()
Date: Thu, 8 Dec 2011 13:35:27 -0800
Message-ID: <20111208213527.GA20721@kroah.com>
References: <CANEJEGtJ3UmFNyui_SaZ6NF5FFVjZ+_UBg1RC2eif5Lu1YKDsQ@mail.gmail.com>
 <20111208180208.GA16883@kroah.com>
 <CANEJEGvNePLb9KcMO-sGSN81y6mb_zaHHQVujSbJXcCwh3Xcmw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Grant Grundler <grundler@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2.smtp.messagingengine.com ([66.111.4.26]:36107 "EHLO
	out2.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752103Ab1LHVny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2011 16:43:54 -0500
Received: from compute1.internal (compute1.nyi.mail.srv.osa [10.202.2.41])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 35E0D209CB
	for <netdev@vger.kernel.org>; Thu,  8 Dec 2011 16:43:54 -0500 (EST)
Content-Disposition: inline
In-Reply-To: <CANEJEGvNePLb9KcMO-sGSN81y6mb_zaHHQVujSbJXcCwh3Xcmw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 08, 2011 at 11:04:48AM -0800, Grant Grundler wrote:
> On Thu, Dec 8, 2011 at 10:02 AM, Greg KH <greg@kroah.com> wrote:
> > On Wed, Dec 07, 2011 at 02:40:49PM -0800, Grant Grundler wrote:
> >> Hi,
> >> I'm testing asix (USB 100BT ethernet adapter with AX88772) driver
> >> initialization (and shut down) paths and reproduced a
> >> "skb_queue_purge" panic 3 times after a few hundred/thousand
> >> iterations of rmmod/modprobe. I'm inclined to believe
> >> skb_queue_purge() is a victim and not a culprit here.
> >>
> >> =A0I don't know if all 3 "spontaneous reboots" I've seen have the =
same
> >> stack trace as the one I have a record for:
> >
> > Have you tried this on 3.1, and especially, 3.2-rc?
>=20
> Hi Greg,
> I haven't tried any thing later yet.  I would consider it if someone
> could point at a change(s) that might be relevant to the symptom.
>=20
>=20
> > =A0A number of asix
> > patches have gone into the 3.2-rc series, perhaps they might have
> > resolved this problem already?
>=20
> I'm the one who submitted those changes. :)

Heh, oops, sorry about that :)

> asix.c driver I'm testing was pulled directly from davem's net-next
> tree and I believe that's what is in 3.2-rc series now.
>=20
> Those changes only relate to AX88772 and AX88178 bind and reset code.
> suspend/resume support is unchanged  - though I suspect ax*_reset
> functions get called in resume.
>=20
> It's possible this code path in asix.c has *always* been broken. I se=
e
> two drivesr/net/usbnet USB drivers that do this:
>=20
> drivers/net/usb/cdc_ether.c  614 .reset_resume =3D usbnet_resume,
> drivers/net/usb/cdc_ncm.c  1193 .reset_resume =3D usbnet_resume,
>=20
> Even though most usbnet drivers don't,  I'm tempted to add this code
> and "just try it":

Let us know if that works or not.

thanks,

greg k-h
