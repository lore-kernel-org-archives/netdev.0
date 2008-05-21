From: Toyo Abe <tabe@miraclelinux.com>
Subject: Re: [IPV6] ADDRCONF: Defer dad for global address until dad for linklocal
 is completed.
Date: Thu, 22 May 2008 02:30:52 +0900
Message-ID: <48345C4C.6020106@miraclelinux.com>
References: <48324792.5070309@miraclelinux.com>	<20080520.173353.128167700.yoshfuji@linux-ipv6.org>	<4832C3CC.5070609@miraclelinux.com> <20080522.015807.02348209.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:4072 "EHLO
	mail.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932348AbYEURay (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 13:30:54 -0400
In-Reply-To: <20080522.015807.02348209.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <4832C3CC.5070609@miraclelinux.com> (at Tue, 20 May 2008 2=
1:27:56 +0900), Toyo Abe <tabe@miraclelinux.com> says:
>=20
>> I was also thinking so. And I tried it at first.
>> But then, many other test scenarios in TAHI test suite went to FAIL.=
 It
>> was because
>> the tester node send RA with prefix option to the host right after i=
t
>> receives DAD NS
>> from the host, which is obviously in autoconfiguration process for
>> linklocal address.
>=20
> If so, we should complain about the spec / tests.
>
Maybe so.
Well, did you observe the same problem?


>> Since current addrconf code actually accepts RA including prefix opt=
ion=20
>> while DAD for
>> linklocal address is processing, changes of the behaviour looks like=
 a=20
>> degradation for me.
>> Hence, I chose to accept RA at that moment and defer sending DAD NS =
for=20
>> global addresses.
>=20
> Well I don't think so.
> We should choose simpler way - avoid introducing new "unique" state s=
o far.
>=20
> If you really think is worth accepting RA during DAD for link-local
> address, we should cancel all of on-going DADs for global address(es)
> if the RA for link-local address has failed, intead of deferring DAD
> for global address(es).
>
You're right. I agree with you that it'd be better than mine.

Thank you,
-toyo


