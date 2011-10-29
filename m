From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 1/2] bonding: Doesn't support IPv6
Date: Sat, 29 Oct 2011 09:55:29 +0200
Message-ID: <CAHXqBF+CcX=FQNSSsdsEAc9jAqi0G3RNLPjRCcc7wJ+QYnzzSA@mail.gmail.com>
References: <4EAB5455.5080004@8192.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: John <linux@8192.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:46098 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753312Ab1J2Hzu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2011 03:55:50 -0400
Received: by iaby12 with SMTP id y12so4887309iab.19
        for <netdev@vger.kernel.org>; Sat, 29 Oct 2011 00:55:50 -0700 (PDT)
In-Reply-To: <4EAB5455.5080004@8192.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/10/29 John <linux@8192.net>:
> --- a/drivers/net/bonding/bond_main.c =A0 2011-04-19 11:18:48.0000000=
00 -0700
> +++ b/drivers/net/bonding/bond_main.c =A0 2011-10-27 11:26:20.0000000=
00 -0700
[...]
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 v6hash =3D (v6hash >> 16) ^ (v6hash >> =
8) ^ v6hash;

This XORs in only 3 of 4 bytes, and assuming count > 256 (its unlikely
you have more than 256 slaves in bond) the most significant byte is
wasted. It should be:

v6hash ^=3D v6hash >> 16;
v6hash ^=3D v6hash >> 8;

Same for IPv4 part.

OTOH, if that was your intention, then the description in your mail was=
 wrong.

Best Regards,
Micha=B3 Miros=B3aw
