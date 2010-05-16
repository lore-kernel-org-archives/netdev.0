From: David Miller <davem@davemloft.net>
Subject: Re: TCP-MD5 checksum failure on x86_64 SMP
Date: Sun, 16 May 2010 00:30:45 -0700 (PDT)
Message-ID: <20100516.003045.146327908.davem@davemloft.net>
References: <20100507101451.1b4286b7@nehalam>
	<1273252893.2261.84.camel@edumazet-laptop>
	<20100507103639.4f1a51fa@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, bhaskie@gmail.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35102
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753501Ab0EPHag convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 May 2010 03:30:36 -0400
In-Reply-To: <20100507103639.4f1a51fa@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 7 May 2010 10:36:39 -0700

> On Fri, 07 May 2010 19:21:33 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
>> Le vendredi 07 mai 2010 =E0 10:14 -0700, Stephen Hemminger a =E9crit=
 :
>>=20
>> > Forget the per cpu data; the pool should just be scrapped.
>> >=20
>> > The only reason the pool exists is that the crypto hash state whic=
h
>> > should just be moved into the md5_info (88 bytes).  The pseudo
>> > header can just be generated on the stack before passing to the cr=
ypto
>> > code.
>>=20
>>=20
>> Sure, but I'm afraid there is no generic API do do that (if we want =
to
>> reuse crypto/md5.c code).
>=20
> It looks like the pool is just an optimization to avoid opening too
> many crypto API connections.  This should only be an issue if offload=
ing
> MD5.

It's an issue because creating a crypto API context is expensive, so th=
is
influences our connection rates with MD5.
