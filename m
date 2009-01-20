From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH] usb/mcs7830: Don't use buffers from stack for USB transfers
Date: Wed, 21 Jan 2009 00:36:49 +0100
Message-ID: <200901210036.51681.oliver@neukum.org>
References: <200901202345.47792.arnd@arndb.de> <200901210017.19038.arnd@arndb.de> <20090120.152345.78877396.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: arnd@arndb.de, ceggers@gmx.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:59012 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756540AbZATXgV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 18:36:21 -0500
In-Reply-To: <20090120.152345.78877396.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Wednesday 21 January 2009 00:23:45 schrieb David Miller:
> > GFP_NOIO seems out of place in a network driver: there is nothing
> > wrong with waiting for I/O here, so plain GFP_KERNEL should be fine=
=2E
>=20
> There seems to be a large precendence for this in other USB drivers,
> both for networking and storage. =A0Probably a mutex or other locking
> hierarchy issue.

Usb storage uses a lot of infrastructure in error handling. As a storag=
e
interface and another interface can share a device and be reset only
together. All drivers' reset handling must be written as if they were
block devices. Therefore you see a lot of GFP_NOIO in USB.

	Regards
		Oliver

