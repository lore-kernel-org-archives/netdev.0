From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: tc filter u32 match
Date: Thu, 24 May 2012 06:04:38 -0400
Message-ID: <1337853878.3513.11.camel@mojatatu>
References: <32a6182e71dd565206cf39d4cad3f984@justnet.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: adam.niescierowicz@justnet.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:46996 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754760Ab2EXKEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 06:04:42 -0400
Received: by ghrr11 with SMTP id r11so1740047ghr.19
        for <netdev@vger.kernel.org>; Thu, 24 May 2012 03:04:41 -0700 (PDT)
In-Reply-To: <32a6182e71dd565206cf39d4cad3f984@justnet.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-22 at 15:42 +0200, Nie=C5=9Bcierowicz Adam wrote:
> Hello,
>=20
> I'm in the process of building a new shaper, when adding support for=20
> 802.1q
> vlan noticed that u32 can catch network traffic without giving 4 byte=
s
> offset. How is this possible?
>=20

Because we look at where the network header starts?
Why do you expect 4 bytes to be counted?=20

> My environment:
>=20
> eth2 - network card
> eth2.200 - vlan
>=20
> /sbin/tc filter add dev eth2 parent 1:0 prio 5 handle 35: protocol ip=
=20
> u32 divisor 256
> /sbin/tc filter add dev eth2 protocol ip parent 1:0 prio 5 u32 ht 800=
::=20
> match ip dst 31.41.208.32/27 hashkey mask 0x000000ff at 16 link 35:
> /sbin/tc filter add dev eth2 protocol ip parent 1: prio 1 u32 ht 35:2=
4:=20
> match ip dst 31.41.208.36 flowid 1:2e5
>=20
> Here you can see the hits in the rule
> filter parent 1: protocol ip pref 5 u32 fh 35:24:800 order 2048 key h=
t=20
> 35 bkt 24 flowid 1:2e5  (rule hit 44037 success 44037)
>    match 1f29d024/ffffffff at 16 (success 44037 )

I dont see an issue. This looks correct.

>=20
> I found a similar question here=20
> http://serverfault.com/questions/370795/tc-u32-how-to-match-l2-protoc=
ols-in-recent-kernels
>=20

There may have been bugs in the past that someone missed or didnt
report here (likely around the time there was a lot of changes
happening with vlan offloading). Try the latest kernel and=20
if it behaves badly, send a report and a reproducible test case.

cheers,
jamal
