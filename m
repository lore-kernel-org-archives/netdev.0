From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: On Linux rate limiting and the magic value of 34.64 Gbps...
Date: Fri, 25 Mar 2011 08:17:39 +0100
Message-ID: <1301037459.2714.570.camel@edumazet-laptop>
References: <AANLkTi=UTcZ8Q-ULk4CAkbZztYKkDeZHK55LHVDRFH2r@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux NetDev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Maciej =?UTF-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:61943 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933430Ab1CYHRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2011 03:17:45 -0400
Received: by fxm17 with SMTP id 17so889011fxm.19
        for <netdev@vger.kernel.org>; Fri, 25 Mar 2011 00:17:43 -0700 (PDT)
In-Reply-To: <AANLkTi=UTcZ8Q-ULk4CAkbZztYKkDeZHK55LHVDRFH2r@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 25 mars 2011 =C3=A0 00:14 -0700, Maciej =C5=BBenczykowski a=
 =C3=A9crit :
> Hey,
>=20
> The Linux rate limiting code relies on the rate field of struct tc_ra=
tespec.
> This field is a __u32 and measures rate in "bytes per second".
>=20
> This basically means maximum representable rate is 4GB per second.
> This is equivalent to 34.36 Gbps and I just ran across that limit wit=
h
> 40 Gbps (which behaves like 5.64 Gbps because of overflow/truncation)=
=2E
> Seeing as this structure is exposed to userspace for both read and
> write via various netlink paths (in cbq, htb, tbf, etc...) there
> doesn't seem to be a particularly clean way to increase the size of
> this field.  While there is a __reserved field that could
> theoretically be repurposed as some sort of rate bit shift register, =
I
> don't think we can rely on __reserved having been set to zero by
> userspace (by older programs), and we will definitely see problems
> with output by programs (tc) that don't expect to have to parse this
> field to output an understandable rate limit...
>=20
> Anybody have any bright ideas?

Well, netlink is extensible, so we can easily add a new structure, with
64bit fields if necessary.

We did that for 64bit stats already.



