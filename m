From: Oliver Neukum <oliver@neukum.org>
Subject: Re: MBIM device refusing to be enabled
Date: Wed, 09 Oct 2013 13:22:25 +0200
Message-ID: <1381317745.3464.6.camel@linux-fkkt.site>
References: <1381309180.3464.2.camel@linux-fkkt.site>
	 <871u3u21zz.fsf@nemi.mork.no> <87hacqzqi0.fsf@nemi.mork.no>
	 <87d2nezoob.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:42788 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751704Ab3JILW1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 07:22:27 -0400
In-Reply-To: <87d2nezoob.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-09 at 13:09 +0200, Bj=C3=B8rn Mork wrote:
> Bj=C3=B8rn Mork <bjorn@mork.no> writes:

Hi,

>=20
> > Sorry, that was nonsense.  rfkill would only affect the HwRadioStat=
e.
>=20
> Turns out I wasn't completely off anyway... by pure luck ;-)
>=20
> > Looking at the commands following this message, it appears that MM
> > correctly attempts to enable the SwRadioState but fails.  I don't k=
now
> > why.

Cool.

> Is the device by any chance a Sierra Wireless device?

Yes. Rebranded by HP but it is Sierra.
HP lt4111 LTE/EV-DO/HSPA+ Gobi 4G Module

> I was able to recreate the behaviour you see after experimenting a bi=
t
> with my MC7710.  This device (and I assume most other MBIM capable
> Sierra Wireless minicards) can be configured to enter low power mode =
on
> rfkill (W_DISABLE asserted), instead of powering off.  Sony for examp=
le
> are known to configure the built-in Sierra devices in this mode.
>=20
> When low power mode is forced by rfkill this way, the firmware
> erroneously[1] claims
>=20
>  HwRadioState: on
>  SwRadioState: off
>=20
> Any attempt to change this software state using MBIM will fail with
> MBIM_STATUS_FAILURE.  Exactly like your log shows.  The modem must be
> enabled using rfkill before MM can use it. Changing the firmware
> behaviour will not do any good - it will just cause the modem to powe=
r
> off and disappear instead.
>=20
> So I would start looking at rfkill after all.  There are often proble=
ms
> with these platform drivers and newer laptops, due to the lack of
> documentation from the vendors.  Here's one (now fixed) example:
> https://bugzilla.kernel.org/show_bug.cgi?id=3D47751

Thanks. A quick look shows that there's something wrong. There is no
rfkill entry for the device. I am investigating.

	Thank you
		Oliver
