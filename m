From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Fix sock freeing before sock_init_data() with	__sk_free()
Date: Mon, 31 Aug 2009 09:18:46 +0200
Message-ID: <4A9B7956.40507@gmail.com>
References: <20090830222340.GA17454@ami.dom.local> <4A9B6D23.9090505@gmail.com> <20090831063648.GB5005@ff.dom.local> <4A9B72B1.2040908@gmail.com> <20090831070733.GC5005@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:34123 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927AbZHaHSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 03:18:50 -0400
In-Reply-To: <20090831070733.GC5005@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski a =E9crit :
> On Mon, Aug 31, 2009 at 08:50:25AM +0200, Eric Dumazet wrote:
>> Jarek Poplawski a =E9crit :
>>> On Mon, Aug 31, 2009 at 08:26:43AM +0200, Eric Dumazet wrote:
>>>> Jarek Poplawski a =E9crit :
>>>>> After recent changes sk_free() frees socks conditionally and depe=
nds
>>>>> on sk_wmem_alloc beeing set e.g. in sock_init_data(). But in some
>>>>> cases sk_free() is called earlier, usually after other alloc erro=
rs.
>>>>> This patch fixes it by exporting and using __sk_free() directly.
>>> ...
>>>> Very nice catch Jarek, but dont you think it would be cleaner to m=
ake sure
>>>> we can call sk_free() right after sk_alloc() instead, and not expo=
rting
>>>> __sk_free() ?
>>>>
>>>> ie initialize wmem_alloc in sk_alloc() instead of initializing it =
in=20
>>>> sock_init_data() ?
>>>>
>>> Most probably it should be better. But I meant this fix for -net an=
d
>>> didn't wan't to break too much... So, if you're sure it's OK feel f=
ree
>>> to send your version. (Or it could be changed like this in the -nex=
t.)
>> Well, patch is yours, not mine, and I am confident it is OK.
>=20
> Well, it's from you, and I guess you'll sign off too, but if you
> think so...
> =20
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
>=20
> Thanks,
> Jarek P.
>=20

Give me a few hours to review sk_alloc() call sites, test patch and off=
icially submit it.

Thanks
