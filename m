From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: fix fib metrics
Date: Thu, 24 Mar 2011 23:18:27 +0100
Message-ID: <1301005107.2714.113.camel@edumazet-laptop>
References: <AANLkTik6+TrjiC6ZF+KHhZ1iPzEe2jDayr363C0HgQN4@mail.gmail.com>
	 <1300980118.3747.42.camel@edumazet-laptop>
	 <AANLkTikZhT5LaA-UEXniDvkneH8JScaVaCaCd4LT59cV@mail.gmail.com>
	 <1300983340.3747.44.camel@edumazet-laptop>
	 <1300986084.3747.101.camel@edumazet-laptop>
	 <AANLkTik+Rf45wUxN86t+Zp7+AXjcJsy0vmZgvmLj-95x@mail.gmail.com>
	 <1300992308.3747.205.camel@edumazet-laptop>
	 <AANLkTin_gxMF1hyK_yhN+G9UGfcBKAhPE24r7tLe5j3D@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Alessandro Suardi <alessandro.suardi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:56389 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932652Ab1CXWTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2011 18:19:06 -0400
In-Reply-To: <AANLkTin_gxMF1hyK_yhN+G9UGfcBKAhPE24r7tLe5j3D@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 24 mars 2011 =C3=A0 23:11 +0100, Alessandro Suardi a =C3=A9cri=
t :

> On a -git14 kernel + both the fib metrics and the above git diff, I
> strace'd vpnc
>  and found out this (first triplet of public IP masked intentionally)
>=20
> [root@duff tmp]# egrep 'execve|garbage' strace.log |egrep '/ip|garbag=
e'
> [pid  4228] execve("/sbin/ip", ["/sbin/ip", "route", "get",
> "xxx.9.13.212"], [/* 32 vars */]) =3D 0
> [pid  4231] execve("/sbin/ip", ["/sbin/ip", "route", "replace",
> "10.175.0.0/19", "dev", "tun0"], [/* 32 vars */]) =3D 0
> [pid  4232] execve("/sbin/ip", ["/sbin/ip", "route", "flush",
> "cache"], [/* 32 vars */]) =3D 0
> [pid  4234] execve("/sbin/ip", ["/sbin/ip", "route", "get",
> "xxx.9.13.212"], [/* 32 vars */]) =3D 0
> [pid  4237] execve("/sbin/ip", ["/sbin/ip", "route", "add",
> "xxx.9.13.212", "via", "192.168.1.1", "dev", "eth1", "src",
> "192.168.1.8", "ipid", "0x043f", "advmss", "1400"], [/* 32 vars */]) =
=3D
> 0
> [pid  4237] write(2, "Error: either \"to\" is duplicate,"..., 57Error=
:
> either "to" is duplicate, or "ipid" is a garbage.
>=20
> 192.168.1.1 is my DSL router and 192.168.1.8 is my computer's wireles=
s IP.
>=20
> Does this ring any bell ?
>=20
>=20

Not a kernel error, but a tool error ?


(ipid is only displayed by "ip ro show")

grep ipid */*.c
ip/iproute.c:				fprintf(fp, " ipid 0x%04x", ci->rta_id);


