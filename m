From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [BUG] UDP : bind() checks are not complete
Date: Tue, 05 Jun 2007 22:22:36 +0200
Message-ID: <4665C60C.1000406@cosmosbay.com>
References: <20070605191536.cc9a4719.dada1@cosmosbay.com> <20070605.130219.35356925.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:41360 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764166AbXFEUWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 16:22:45 -0400
In-Reply-To: <20070605.130219.35356925.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Tue, 5 Jun 2007 19:15:36 +0200
>=20
>> I discovered one big problem with UDP binding in 2.6.22-rc4 :
>=20
> Thanks for finding this problem, the crux of the issue is
> INADDR_ANY.

Well, I feel guilty as I was initial patch submiter :(

>=20
>> We really should check no socket is bound to XXX.XXX.XXX.XXX:32769. =
With current hashing,=20
>> it means checking all slots in udptable[] :(
>>
>> Our choices are :
>>
>> 1) Drop all thoses patches and re-think them for 2.6.23 eventually
>> 2) Add the extra check for ANY_ADDR sockets and perform a full scan
>>
>> What do you think ?
>=20
> Does checking for INADDR_ANY sockets really require a full scan?
> It should just need two hash probes as far as I can tell to see
> if there is "0.0.0.0:PORT" bound already.

Well, we might have 1000 ip addresses on the machine (or not :) ), and

192.168.0.1:PORT ... 192.168.0.254:PORT already bound.

