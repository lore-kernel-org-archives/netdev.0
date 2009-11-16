From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: Fix the rollback test in dev_change_name()
Date: Mon, 16 Nov 2009 12:08:22 +0100
Message-ID: <4B0132A6.7090305@gmail.com>
References: <4AEB7BB1.9000901@gmail.com>	<20091102.000549.114598716.davem@davemloft.net>	<20091116093024.GA13115@ff.dom.local> <20091116.024936.14048478.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55346 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752028AbZKPLIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 06:08:20 -0500
In-Reply-To: <20091116.024936.14048478.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Mon, 16 Nov 2009 09:30:24 +0000
>=20
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>>
>> net: Fix the rollback test in dev_change_name()
>>
>> In dev_change_name() an err variable is used for storing the origina=
l
>> call_netdevice_notifiers() errno (negative) and testing for a rollba=
ck
>> error later, but the test for non-zero is wrong, because the err mig=
ht
>> have positive value as well - from dev_alloc_name(). It means the
>> rollback for a netdevice with a number > 0 will never happen. (The e=
rr
>> test is reordered btw. to make it more readable.)
>>
>> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
>> Cc: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Ok.
>=20
> Eric please give your signoff and I'll put this where it needs
> to go.
>=20

I finaly understood why I got stuck on this one : I thought dev_alloc_n=
ame()
was returning 0 in case of success. The test was thus realy obscure for=
 me.

So Jarek patch is pretty clear now I saw the light !

Thanks

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

