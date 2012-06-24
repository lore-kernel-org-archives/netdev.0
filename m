From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH net] net: qmi_wwan: fix Oops while disconnecting
Date: Sun, 24 Jun 2012 14:13:08 +0200
Message-ID: <201206241413.08339.oliver@neukum.org>
References: <1340356279-3124-1-git-send-email-bjorn@mork.no> <201206232255.08319.oliver@neukum.org> <877guxhx44.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ming Lei <tom.leiming@gmail.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org,
	Marius =?utf-8?q?Bj=C3=B8rnstad_Kotsbak?=
	<marius.kotsbak@gmail.com>
To: =?utf-8?q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:36274 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753383Ab2FXMNI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2012 08:13:08 -0400
In-Reply-To: <877guxhx44.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Sonntag, 24. Juni 2012, 11:34:19 schrieb Bj=C3=B8rn Mork:
> Oliver Neukum <oliver@neukum.org> writes:

> > 1. We mirror the minidrivers closely, which reduces errors
> > 2. unbind() is called with the data anyway and after disconnect()
> >     the intfdata is not valid anyway, because the interface may hav=
e been
> >     reprobed.
>=20
> Sorry, I did not understand what you meant we should do here.  The ex=
tra
> usb_set_intfdata(, NULL) in usbnet_disconnect() won't make any
> difference for that piece of code, will it?

The point is that if it may be set to NULL, we always want it to be set=
 to
NULL, so we catch bugs.

> And the USB core ensures that intfdata is set to NULL before any
> reprobing, so that will never be a problem.  That's the reason why it
> seems redundant setting it in usbnet_disconnect().

The point is that if there is a problem because intfdata is set to NULL=
,
there is very likely a problem in form of a race condition, if intfdata
were not set to NULL in usbnet's disconnect handler.

	Regards
		Oliver
