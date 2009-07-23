From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] USB host CDC Phonet network interface driver
Date: Thu, 23 Jul 2009 10:34:52 -0400
Message-ID: <1248359692.774.22.camel@localhost.localdomain>
References: <1248177515-12712-1-git-send-email-remi.denis-courmont@nokia.com>
	 <20090722101102.4aba96bd@lxorguk.ukuu.org.uk>
	 <1248254134.28545.111.camel@violet>
	 <200907221407.29275.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ext Marcel Holtmann <marcel@holtmann.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Oliver Neukum <oliver@neukum.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:59974 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750943AbZGWOea (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jul 2009 10:34:30 -0400
In-Reply-To: <200907221407.29275.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-07-22 at 14:07 +0300, R=C3=A9mi Denis-Courmont wrote:
> On Wednesday 22 July 2009 12:15:34 ext Marcel Holtmann wrote:
> > Hi Alan,
> >
> > > > The AT stuff is really problematic. Look at the hoops ISDN and =
software
> > > > modem drivers go through to emulate AT commands. I know even of=
 a
> > > > CDC-ACM modem which can't deal with AT commands inline (that's =
within
> > > > spec). It seems to me we should have a modem API in kernel.
> > >
> > > For devices which don't deal in AT commands probably but for devi=
ces
> > > whose firmware provides an AT command interface over serial I wou=
ld
> > > disagree.
> >
> > I fully agree here. Even if you think you get AT commands under con=
trol,
> > you really won't in the end. That standard is so wildly mis-interpr=
eted
> > that it is not even funny anymore.
>=20
> Possibly. Does anyone known of any "species" bypassing AT commands en=
tirely,=20
> other than Phonet? as far as GPRS is concerned?

There are any number of devices that expose only one AT port (which of
course gets used by PPP for data) and then a proprietary port.  The
proprietary port usually uses a custom USB protocol that can also handl=
e
SMS, status, RSSI, etc while the AT/PPP port is being used by ppp.

So if that's the case for phonet, maybe you just want to provide either
(a) documentation of the setup/status/sms/etc protocols, or (b) a shim
library implementation for them that handles communication with the
device itself.

But IMHO, the call setup stuff is probably better done from userspace.
It's a really hard API to abstract.  I guess you could write a netlink
API for it like we have for 802.11, but with GSM/CDMA the standards are
so widely ignored that it's just going to be impossible to get a stable
kernel API for anything like this.  The actual logic and higher-level
stuff has gotta be in userspace, while the low-level communication
channel bits (serial, USB, phonet, etc) should live in the kernel.

Dan

