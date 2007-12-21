From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [TCP] IPV6 : Change a divide into a right shift in tcp_v6_send_ack()
Date: Fri, 21 Dec 2007 09:11:39 +0100
Message-ID: <476B753B.7090605@cosmosbay.com>
References: <476B574E.80601@cosmosbay.com>	<20071221.155030.131184865.yoshfuji@linux-ipv6.org>	<476B65F8.10201@cosmosbay.com> <20071221.162833.82587283.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:41924 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753506AbXLUILz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 03:11:55 -0500
In-Reply-To: <20071221.162833.82587283.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E a =C3=A9crit :
> In article <476B65F8.10201@cosmosbay.com> (at Fri, 21 Dec 2007 08:06:=
32 +0100), Eric Dumazet <dada1@cosmosbay.com> says:
>=20
>> YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E a =C3=A9cri=
t :
>>> In article <476B574E.80601@cosmosbay.com> (at Fri, 21 Dec 2007 07:0=
3:58 +0100), Eric Dumazet <dada1@cosmosbay.com> says:
>>>
>>>> Because tot_len is signed in tcp_v6_send_ack(), tot_len/4 forces c=
ompiler
>>>> to emit an integer divide, while we can help it to use a right shi=
ft,
>>>> less expensive.
>>> Are you really sure?
>>> At least, gcc-4.1.2-20061115 (debian) does not make any difference.
>>>
>>> And, IMHO, because shift for signed variable is fragile, so we shou=
ld
>>> avoid using it.
>>>
>> Yes I am sure, but maybe you are on x86_64 ?
>>
>> gcc-4.2.2 on x86
>=20
> I'm on gcc-4.1.2 20061115 (prerelease) (Debian 4.1.1-21), on x86 (i68=
6).
> Maybe compiler difference?!

hum, more probably a .config difference. Try with

CONFIG_CC_OPTIMIZE_FOR_SIZE=3DY

(default config)


