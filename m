From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] Fix build errors on 32bit platforms with new ktime
Date: Wed, 25 Apr 2007 00:12:38 +0200
Message-ID: <462E80D6.8060609@cosmosbay.com>
References: <20070425.011028.113320997.yoshfuji@linux-ipv6.org>	<20070424183827.adb60ae0.dada1@cosmosbay.com>	<20070424100420.2860db68@dxpl.pdx.osdl.net>	<20070425.065539.104129657.yoshfuji@linux-ipv6.org> <20070424145754.1a37f666@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>, bunk@stusta.de, davem@davemloft.net,
	netdev@vger.kernel.org, tglx@linutronix.de
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:38255 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422667AbXDXWQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 18:16:09 -0400
In-Reply-To: <20070424145754.1a37f666@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger a =C3=A9crit :
> On Wed, 25 Apr 2007 06:55:39 +0900 (JST)
> YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E  <yoshfuji@l=
inux-ipv6.org> wrote:
>=20
>> In article <20070424100420.2860db68@dxpl.pdx.osdl.net> (at Tue, 24 A=
pr 2007 10:04:20 -0700), Stephen Hemminger <shemminger@linux-foundation=
=2Eorg> says:
>>
>>> Yoshifuji-san had the right idea, but ktime_to_us needs to be defin=
ed
>>> in a way that works on both 64 and 32bit platforms.
>> No, this does not cure.
>>> =20
>>> +#define ktime_to_us(kt)			((kt).tv64 / NSEC_PER_SEC)
>>> +
>> NSEC_PER_USEC?
>=20
> On 64 bit platforms, ktime stores nano-seconds in a 64 bit value, so
> this is correct.

Really ? You introduce a 10^6 error and say it's correct ?

We believe the correct divisor is 10^3 to get usec from nsec, not 10^9

