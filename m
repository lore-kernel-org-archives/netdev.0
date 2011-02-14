From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [PATCH] core: dev: don't call BUG() on bad input
Date: Mon, 14 Feb 2011 15:23:13 +0300
Message-ID: <20110214122313.GA10062@albatros>
References: <1297680967-11893-1-git-send-email-segoon@openwall.com>
 <4D591D04.4050000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Changli Gao <xiaosuo@gmail.com>,
	Jesse Gross <jesse@nicira.com>, netdev@vger.kernel.org
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:64487 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754086Ab1BNMXU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 07:23:20 -0500
Content-Disposition: inline
In-Reply-To: <4D591D04.4050000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Nicolas,

On Mon, Feb 14, 2011 at 13:16 +0100, Nicolas de Peslo=FCan wrote:
> >-	BUG_ON(strlen(name)>=3D sizeof(dev->name));
> >+	if (strnlen(name, sizeof(dev->name))>=3D sizeof(dev->name)) {

Ehh...  Space after ")" is needed :)

> "size_t strnlen(const char *s, size_t maxlen) : The strnlen()
> function returns strlen(s), if that is less than maxlen, or maxlen
> if there is no '\0' character among the first maxlen characters
> pointed to by s."
>=20
> How can strnlen(name, sizeof(dev->name)) be greater than sizeof(dev->=
name)?
>=20
> Shouldn't it be "if (strnlen(name, sizeof(dev->name)) =3D=3D sizeof(d=
ev->name))" instead?

Not a big deal, but MO it's better to guard from everything that
is not a good input by negating the check.  strnlen() < sizeof() is OK,
strnlen() >=3D sizeof() is bad.  Is "=3D=3D" more preferable for net/ c=
oding style?


--=20
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environ=
ments
