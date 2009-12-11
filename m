From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel Panics in the network stack
Date: Fri, 11 Dec 2009 22:39:43 +0100
Message-ID: <4B22BC1F.607@gmail.com>
References: <4B22B4F2.8080605@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Kevin Constantine <kevin.constantine@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39519 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758218AbZLKVjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 16:39:39 -0500
In-Reply-To: <4B22B4F2.8080605@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 11/12/2009 22:09, Kevin Constantine a =E9crit :
> Hey Everyone-
>=20
> I've been playing with an ARM based linuxstamp
> http://opencircuits.com/Linuxstamp, and I've been seeing kernel panic=
s
> with both 2.6.28.3, and 2.6.30 within an hour or so of turning the
> linuxstamp on.  The stack traces always seem to point at functions
> related to networking.  I've pasted a couple of the crash outputs bel=
ow.
>  The linuxstamp isn't typically doing anything when the crashes occur=
,
> in fact it'll crash even if I haven't logged in.
>=20
> If I ifconfig the interface down, the linuxstamp stays up indefinitel=
y.
>  Any pointers in one direction or another would be much appreciated.
>=20
> I'm not sure if this is the right audience to help out or if the arm
> lists might be better.  But in any event, any help would be really
> appreciated.
>=20
>=20
> linuxstamp login: Unable to handle kernel paging request at virtual
> address 183cb7b0
> pgd =3D c0004000
> [183cb7b0] *pgd=3D00000000
> Internal error: Oops: 0 [#1] PREEMPT
> Modules linked in:
> CPU: 0    Not tainted  (2.6.30-00002-g0148992 #13)
> PC is at 0x183cb7b0
> LR is at __udp4_lib_rcv+0x43c/0x72c

Could you disassemble your vmlinux file, __udp4_lib_rcv function around=
 LR
<c024ff4c>, to see which function was called ? This function then calle=
d=20
a wrong pointer (0x183cb7b0 not a kernel pointer)

Maybe a kernel stack corruption, or bad ram, ...
