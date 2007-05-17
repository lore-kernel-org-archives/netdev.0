From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [FIX][PATCH] ipv6 addrconf.c : wrong handling of non-ipv6 hardware
 since 2.6.21
Date: Thu, 17 May 2007 22:41:42 +0200
Message-ID: <464CBE06.30204@hartkopp.net>
References: <464C886F.50703@hartkopp.net> <20070518.024940.120305926.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:54350 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754993AbXEQUmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2007 16:42:06 -0400
In-Reply-To: <20070518.024940.120305926.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E schrieb:
> In article <464C886F.50703@hartkopp.net> (at Thu, 17 May 2007 18:53:0=
3 +0200), Oliver Hartkopp <socketcan@hartkopp.net> says:
>
>  =20
>> +static int ipv6_hwtype(struct net_device *dev)
>> +{
>> +    if ((dev->type =3D=3D ARPHRD_ETHER) ||
>> +        (dev->type =3D=3D ARPHRD_LOOPBACK) ||
>> +#if defined(CONFIG_IPV6_SIT) || defined(CONFIG_IPV6_SIT_MODULE)
>> +        (dev->type =3D=3D ARPHRD_SIT) ||
>> +#endif
>> +        (dev->type =3D=3D ARPHRD_TUNNEL6) ||
>> +        (dev->type =3D=3D ARPHRD_FDDI) ||
>> +        (dev->type =3D=3D ARPHRD_IEEE802_TR) ||
>> +        (dev->type =3D=3D ARPHRD_ARCNET) ||
>> +        (dev->type =3D=3D ARPHRD_INFINIBAND))
>> +        return 1;
>> +
>> +    return 0;
>> +}
>> +
>>    =20
>
> Please remove #if, or please provide for other
> dependencies as well (e.g., CONFIG_IPV6_TUNNEL etc.)
>
> Otherwise, I would agree.
>
>  =20
Hello Hideaki,

thanks for your (positive) feedback.
Indeed ARPHRD_SIT is the only hardware type that's explicitely #if 'ed=20
in the addrconf.c code. Any other ARPHRD_* is not conditional to any=20
CONFIGs. E.g. there is no #ifdef CONFIG_IPV6_TUNNEL arround the other=20
ARPHRD_TUNNEL6 stuff in addrconf.c.

So the current patch meets the exact functional extension to the other=20
code, where only ARPHRD_SIT is in #if 's.
Of course it is no problem to remove the #if defined(CONFIG_IPV6_SIT) =20
=2E.. but this would be the only place in the code then.

Are you sure, that you really want have a divergent codestyle only here=
=20
in ipv6_hwtype()?

If so i can post it of course.

Best Regards,
Oliver

