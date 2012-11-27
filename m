From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH 1/2] smsc75xx: refactor entering suspend modes
Date: Tue, 27 Nov 2012 14:46:38 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.1211271443150.1489-100000@iolanthe.rowland.org>
References: <87y5hm9ap5.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steve Glendinning <steve@shawell.net>,
	netdev <netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>
To: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iolanthe.rowland.org ([192.131.102.54]:43088 "HELO
	iolanthe.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753938Ab2K0Tqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 14:46:39 -0500
In-Reply-To: <87y5hm9ap5.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Nov 2012, Bj=C3=B8rn Mork wrote:

> Steve Glendinning <steve@shawell.net> writes:
>=20
> > Hi Bjorn,
> >
> > On 27 November 2012 17:21, Steve Glendinning <steve@shawell.net> wr=
ote:
> >> Hi Bjorn,
> >>
> >>>> +     smsc75xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
> >>>
> >>> As mentioned in another comment to the smsc95xx driver: This is w=
eird.
> >>> Do you really need to do that?
> >>>
> >>> This is an USB interface driver.  The USB device is handled by th=
e
> >>> generic "usb" driver, which will do the right thing.  See
> >>> drivers/usb/generic.c and drivers/usb/core/hub.c
> >>
> >> Thanks, I've tested removing all these calls from the driver and
> >> wakeup functionality seems to still work.
> >>
> >> I'll resubmit my smsc75xx enhancement patchset with this change on=
ce
> >> I've done some more testing.
> >
> > Further testing shows that removing these calls stop wakeup from
> > system suspend working (although don't appear to impact runtime
> > autosuspend).  Have I missed a flag or somewhere that causes
> > udev->do_remote_wakeup to be set in the code you posted?
>=20
> udev->do_remote_wakeup is set in choose_wakeup() in
> drivers/usb/core/driver.c.  AFAICS it is always set as long as
> device_may_wakeup(&udev->dev) is true.

That's right.  But is device_may_wakeup(&udev->dev) true?

By default it wouldn't be.  The normal way to set it is for the user or=
=20
a program to do:

	echo enabled >/sys/bus/usb/devices/.../power/wakeup

Of course, a driver could disregard the user's choice and set the flag=20
by itself.

Alan Stern
