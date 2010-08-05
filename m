From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [patch] isdn: fix information leak
Date: Thu, 5 Aug 2010 21:24:46 +0800
Message-ID: <AANLkTikd=rgUMFTjZ=K6Q7_X8HvO33QSQfZJ5TH7xz-h@mail.gmail.com>
References: <20100805093806.GF9031@bicker> <AANLkTin4jtYuaxYfxDAgST857sD2K4Q28mPcPW=xd-V3@mail.gmail.com>
	<20100805101938.GH9031@bicker> <AANLkTi=8ThVqTHpQmDfoon02C-VZ0JwBRtSrU7dzvvNt@mail.gmail.com>
	<20100805113721.GI9031@bicker> <AANLkTikGNr8aVV7Rryq_dvSuYjUbEo_gRDLW3d49YwF-@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33560 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758073Ab0HENZI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 09:25:08 -0400
In-Reply-To: <AANLkTikGNr8aVV7Rryq_dvSuYjUbEo_gRDLW3d49YwF-@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 5, 2010 at 9:18 PM, Changli Gao <xiaosuo@gmail.com> wrote:
> On Thu, Aug 5, 2010 at 7:37 PM, Dan Carpenter <error27@gmail.com> wro=
te:
>>
>> Both strncpy() and strlcpy() take a limitter. =A0The difference is t=
hat
>> strlcpy() always takes on a terminator and strncpy() only adds a
>> terminator if there is space.
>>
>> strlcpy() is a BSD function that never caught on in Linux. =A0The gl=
ibc
>> maintainers think that if you accidentally chop off the last part of=
 a
>> word that makes you an idiot. =A0They think you should known the len=
gth of
>> your data at all times and use memcpy() or a proper string library.
>>
>> I prefer strlcpy() to strncpy(). =A0Some people do stuff like:
>> =A0 =A0 =A0 =A0strncpy(bar, foo, n);
>> =A0 =A0 =A0 =A0bar[n] =3D '\0';
>> You have to read through the code to find if n is "sizeof(bar)" or
>> "sizeof(bar) - 1". =A0Which is a pain in the arse. =A0strlcpy() is e=
xplicit
>> and it's just one line of code instead of two.
>>
>> The other tricky thing you should remember about strncpy() is that t=
he
>> posix version writes NUL chars from the end of the string to the
>> limitter but the kernel version only copies one NUL character.
>>
>
> You should spend some time on reading the source code of strlcpy() an=
d
> strncpy().
>
> the example use of them is:
>
> char dst[24];
> char *src =3D "test";
>
> strncpy(dst, src, sizeof(dst) - 1);

Oh, Sorry, I made a mistake here. As you said, the code should be
 strncpy(dst, src, sizeof(dst));
 dst[sizeof(dst) - 1] =3D '\0';

However, if you use strlcpy(), you really don't need to zero the dst bu=
ffer.

> strlcpy(dst, src, sizeof(dst));
>
> both of them don't need to zero dst, and they don't need to pad zero
> at then end of the dst.
>



--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
