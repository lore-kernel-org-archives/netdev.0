From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH RFC 2/5] vringfd base/offset
Date: Tue, 8 Apr 2008 07:14:36 +0200
Message-ID: <200804080714.37011.arnd@arndb.de>
References: <200804052202.09157.rusty@rustcorp.com.au> <200804052204.28518.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Max Krasnyansky <maxk@qualcomm.com>
To: virtualization@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:51900 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751121AbYDHFOo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 01:14:44 -0400
In-Reply-To: <200804052204.28518.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 05 April 2008, Rusty Russell wrote:
> =A0static const struct file_operations vring_fops =3D {
> =A0=A0=A0=A0=A0=A0=A0=A0.release=A0=A0=A0=A0=A0=A0=A0=A0=3D vring_rel=
ease,
> =A0=A0=A0=A0=A0=A0=A0=A0.write=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=3D vring=
_write,
> =A0=A0=A0=A0=A0=A0=A0=A0.poll=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=3D vri=
ng_poll,
> +=A0=A0=A0=A0=A0=A0=A0.ioctl=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=3D vring_i=
octl,
> =A0};

This should also set the .compat_ioctl pointer. If the argument=20
is defined as an actual memory location instead of a pointer,
you also don't need the compat_ptr() conversion for s390x, so
both can point to the same vring_ioctl function.

	Arnd <><
