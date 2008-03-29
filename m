From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: kernel 2.6.25-rc7 highly unstable on high load
Date: Sat, 29 Mar 2008 09:31:55 +0100
Message-ID: <47EDFE7B.7030700@cosmosbay.com>
References: <47EBC641.8040405@cosmosbay.com> <20080327183745.M9944@visp.net.lb> <47EBEDC9.6080100@cosmosbay.com> <20080327.150308.205829519.davem@davemloft.net> <20080328052543.M60286@visp.net.lb> <47EC8701.1080604@cosmosbay.com> <20080328073854.M73368@visp.net.lb> <47ECA24C.10803@cosmosbay.com> <47ED1583.5010204@cosmosbay.com> <20080328132359.15573601@speedy> <20080328203358.M8487@visp.net.lb> <47ED6066.2010407@cosmosbay.com> <20080328220902.M5377@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604006av.neufgp.fr ([84.96.92.121]:48310
	"EHLO neuf-infra-smtp-out-sp604006av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752940AbYC2IcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2008 04:32:11 -0400
In-Reply-To: <20080328220902.M5377@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko a =C3=A9crit :
> It looks like probably i did mistake while applying it. Very strange,=
 cause i=20
> rechecked it, and i did make clean before building system image.
> I will make sure on vanilla code that everything is fine.
>=20
> Btw, i see permanently 4 "delayed"(?) records.
>=20
> [ 6261.050827] dstgc [0] lo     09E9FED5        09E9FED5       =20
> 80000000        5       29      0       8F323353        0       0    =
  =20
> 0       00      -1  009E9FED5
> [ 6261.050834] dstgc [1] lo     09E9FED5        09E9FED5       =20
> 80000000        37      358     0       FC9B62D4        0       0    =
  =20
> 0       00      -1  009E9FED5
> [ 6261.050838] dstgc [2] lo     09E9FED5        09E9FED5       =20
> 80000000        4       8       0       7048DF48        0       0    =
  =20
> 0       00      -1  009E9FED5
> [ 6261.050842] dstgc [3] lo     09E9FED5        09E9FED5       =20
> 80000000        6       5       0       6924E846        0       0    =
  =20
> 0       00      -1  009E9FED5
> [ 6261.050851] dst_total: 129123 delayed: 4 work_perf: 0 expires: 680=
00=20
> elapsed: 27 us
>=20
> Especially interesting one with refcnt 37 and dst.__use 358. I check =
for=20
> around 5 minutes - there is no traffic at all. This record staying fo=
r long=20
> time and there is no activity on it over "tcpdump -ni any host=20
> 212.98.155.252" , and it is not flushing it over ip route flush cache=
=2E
>=20

This route with refcnt 37 has Source IP =3D FC9B62D4, which is 212.98.1=
55.252

Check that you dont have some tcp sessions with this remote address :

ss dst 212.98.155.252

As long as you have no activity on it, refcnt wont change.

