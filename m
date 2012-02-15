From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Re: Re: Re: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Wed, 15 Feb 2012 07:06:56 +0100
Message-ID: <1329286016.2555.41.camel@edumazet-laptop>
References: <8633039.fHPLx6GNq3@localhost.localdomain>
	 <5133914.uYLb0gnNTc@localhost.localdomain>
	 <1329235210.4818.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <5781419.24ZaHfTAxC@localhost.localdomain>
	 <1329280993.2555.21.camel@edumazet-laptop>
	 <CADVnQykxiGBXCKdr=G+T190EA14RnAs0HJ69imsN0h8JKMS4jw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: alekcejk@googlemail.com, netdev@vger.kernel.org
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:58258 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753180Ab2BOGHA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 01:07:00 -0500
Received: by werb13 with SMTP id b13so388200wer.19
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2012 22:06:58 -0800 (PST)
In-Reply-To: <CADVnQykxiGBXCKdr=G+T190EA14RnAs0HJ69imsN0h8JKMS4jw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 15 f=C3=A9vrier 2012 =C3=A0 01:03 -0500, Neal Cardwell a =C3=
=A9crit :
> There are some potentially interesting differences in sysctl values:
>=20
> > diff -u /tmp/sysctl-a-3.1.txt /tmp/sysctl-a-3.2.txt  | grep mem_def
> -net.core.wmem_default =3D 114688
> -net.core.rmem_default =3D 114688
> +net.core.wmem_default =3D 163840
> +net.core.rmem_default =3D 163840
>=20
> Can you please try running this as root on the 3.2 kernel and then se=
e
> what sort of performance you get:
>=20
> sysctl net.core.rmem_default=3D114688
>=20
> This should make the 3.2 config closer to the 3.1 config. Should be
> interesting to see if the behavior is more similar when that happens.
>=20
> neal

These changes are normal, since skb truesize  now include shared_info.

By the way, these params are not used for tcp streams.

This is why I asked netstat -s values, to check if we had drops because
of truesize limits.

Its not the case here since skb are not too fat (as some NICS can do,
using a full PAGE to hold a single 1500 bytes frams)
