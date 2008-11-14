From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: speedup dst_release()
Date: Fri, 14 Nov 2008 10:04:24 +0100
Message-ID: <491D3F18.5030505@cosmosbay.com>
References: <491D323B.9030802@cosmosbay.com> <20081114.005437.09284570.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:35748 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750727AbYKNJEf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 04:04:35 -0500
In-Reply-To: <20081114.005437.09284570.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Fri, 14 Nov 2008 09:09:31 +0100
>=20
>> During tbench/oprofile sessions, I found that dst_release() was in t=
hird position.
>  ...
>> Instead of first checking the refcount value, then decrement it,
>> we use atomic_dec_return() to help CPU to make the right memory tran=
saction
>> (ie getting the cache line in exclusive mode)
>  ...
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>=20
> This looks great, applied, thanks Eric.
>=20

Thanks David


I think I understood some regressions here on 32bits=20

offsetof(struct dst_entry, __refcnt) is 0x7c again !!!

This is really really bad for performance

I believe this comes from a patch from Alexey Dobriyan
(commit def8b4faff5ca349beafbbfeb2c51f3602a6ef3a
net: reduce structures when XFRM=3Dn)


This kills effort from Zhang Yanmin (and me...)

(commit f1dd9c379cac7d5a76259e7dffcd5f8edc697d17
[NET]: Fix tbench regression in 2.6.25-rc1)


Really we must find something so that this damned __refcnt is starting =
at 0x80


