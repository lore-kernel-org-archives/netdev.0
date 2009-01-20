From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] usb/mcs7830: Don't use buffers from stack for USB transfers
Date: Wed, 21 Jan 2009 00:17:18 +0100
Message-ID: <200901210017.19038.arnd@arndb.de>
References: <34115.192.168.0.40.1232483361.squirrel@server> <200901202345.47792.arnd@arndb.de> <20090120.144719.120709836.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ceggers@gmx.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:62866 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752958AbZATXR0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 18:17:26 -0500
In-Reply-To: <20090120.144719.120709836.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 20 January 2009, David Miller wrote:
> You cannot DMA from/to the kernel stack, because it might not be in
> the aliased linear mapping of physical memory. =A0It could even be
> vmalloc()'d memory on some platforms.

Ok, I see. It seems a bit of a waste to do a kmalloc for something
that is guaranteed to be just a few bytes, but allocating the
buffer per-device would mean another mutex, which has about the
same overhead, so I'm basically ok with the patch.

> +       buffer =3D kmalloc(size, GFP_NOIO);

GFP_NOIO seems out of place in a network driver: there is nothing
wrong with waiting for I/O here, so plain GFP_KERNEL should be fine.

> +       if (buffer =3D=3D NULL)
> +               return -ENOMEM;

I'd prefer to write=20

	if (!buffer)

here, as I do elsewhere in the driver.

Otherwise,

Acked-by: Arnd Bergmann <arnd@arndb.de>
