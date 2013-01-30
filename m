From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH net v2] net: usbnet: prevent buggy devices from killing us
Date: Wed, 30 Jan 2013 08:44:35 +0100
Message-ID: <1784756.y7ETz6QMlb@linux-5eaq.site>
References: <1359453088-12370-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Joe Perches <joe@perches.com>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:52312 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751029Ab3A3Hof convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 02:44:35 -0500
In-Reply-To: <1359453088-12370-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 29 January 2013 10:51:28 Bj=F8rn Mork wrote:
> A device sending 0 length frames as fast as it can has been
> observed killing the host system due to the resulting memory
> pressure.
>=20
> Temporarily disable RX skb allocation and URB submission when
> the current error ratio is high, preventing us from trying to
> allocate an infinite number of skbs.  Reenable as soon as we
> are finished processing the done queue, allowing the device
> to continue working after short error bursts.
>=20
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>
Acked-by: Oliver Neukum <oneukum@suse.de>

> ---
> v2 changes:
>  - reset counters in open to avoid starting in previous error state
>  - remove superfluous debug logging.  Errors are logged per packet
>    when debugging is on anyway.
>=20
> The removal of the debug logging should address your concerns, Joe?
>=20
> Note that I have not added any new device reset or the like, Oliver. =
 It
> does not seem to help for the device I am testing.  And being a compo=
site

Well, this is a very buggy firmware.

> device, where this bug only affects *one* function, I do not think it
> would be appropriate even if it did help.  Note that the device may b=
e

Reset is used by storage and HID whether the device is composite
or not.
But if reset doesn't actually work, the point is moot.

	Regards
		Oliver
