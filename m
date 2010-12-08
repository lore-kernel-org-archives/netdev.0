From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: avoid a possible divide by zero
Date: Wed, 08 Dec 2010 09:33:13 +0100
Message-ID: <1291797193.2883.28.camel@edumazet-laptop>
References: <201012071639.58884.Martin@lichtvoll.de>
	 <1291757563.21627.15.camel@bwh-desktop>
	 <1291759435.5324.25.camel@edumazet-laptop>
	 (sfid-20101208_091329_309252_DAE30076)  <201012080923.36086.Martin@lichtvoll.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Martin Steigerwald <Martin@lichtvoll.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:56694 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751446Ab0LHIdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 03:33:18 -0500
Received: by wwa36 with SMTP id 36so896494wwa.1
        for <netdev@vger.kernel.org>; Wed, 08 Dec 2010 00:33:17 -0800 (PST)
In-Reply-To: <201012080923.36086.Martin@lichtvoll.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 08 d=C3=A9cembre 2010 =C3=A0 09:23 +0100, Martin Steigerwal=
d a =C3=A9crit :

> Are there so many sysctls which are likely to freeze the kernel when =
fed=20
> with wrong value? Once could argue for sysctls where invalid values d=
on't=20
> cause any serious harm, its not so important to fix it. I probably co=
uld=20
> have next weeks training members a go at poking creative values in ot=
her=20
> controls as well to see what happens.
>=20

We have many sysctls that can lead to non working machine.

Any kind of limits actually. Just set them to 0 (or maybe a negative
number :( )

0 socket, 0 file descriptor, 0 memory, 0 speed limit, 0 lengthes ...



> So this patch helps other cases as well? Or is it, as I think just a=20
> different approach, to fix the issue my training member brought up, b=
y its=20
> cause instead of or additional to limiting its range?
>=20
> Want to check whether I basically understood the patch. Do you want m=
e to=20
> test it?=20

It has nothing to do with the issue you raised, and is a completely
different subject. I got it while spending 5 minutes yesterday night
grep-ing some sysctls in network tree. 0 value is one of expected value
for this sysctl, but the test was not safe.



