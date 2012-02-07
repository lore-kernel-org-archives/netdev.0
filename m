From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Subject: Re: [PATCH] net: sh_eth: fix skb_over_panic happen
Date: Tue, 07 Feb 2012 17:35:52 +0900
Message-ID: <4F30E268.6010100@renesas.com>
References: <4F30CAA8.5050207@renesas.com>
 <1328601310.2476.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor4.renesas.com ([210.160.252.174]:33311 "EHLO
	relmlor4.renesas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754411Ab2BGIlF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 03:41:05 -0500
Received: from relmlir3.idc.renesas.com ([10.200.68.153])
 by relmlor4.idc.renesas.com ( SJSMS)
 with ESMTP id <0LZ00021BL7SJI70@relmlor4.idc.renesas.com> for
 netdev@vger.kernel.org; Tue, 07 Feb 2012 17:35:52 +0900 (JST)
Received: from relmlac2.idc.renesas.com ([10.200.69.22])
 by relmlir3.idc.renesas.com ( SJSMS)
 with ESMTP id <0LZ000I5WL7SDO60@relmlir3.idc.renesas.com> for
 netdev@vger.kernel.org; Tue, 07 Feb 2012 17:35:52 +0900 (JST)
In-reply-to: <1328601310.2476.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

2012/02/07 16:55, Eric Dumazet wrote:
> Le mardi 07 f=C3=A9vrier 2012 =C3=A0 15:54 +0900, Shimoda, Yoshihiro =
a =C3=A9crit :
[ snip ]
>> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/eth=
ernet/renesas/sh_eth.c
>> index 813d41c..9e899b0 100644
>> --- a/drivers/net/ethernet/renesas/sh_eth.c
>> +++ b/drivers/net/ethernet/renesas/sh_eth.c
>> @@ -817,7 +817,7 @@ static int sh_eth_dev_init(struct net_device *nd=
ev)
>>  		sh_eth_write(ndev, 0, TRIMD);
>>
>>  	/* Recv frame limit set register */
>> -	sh_eth_write(ndev, RFLR_VALUE, RFLR);
>> +	sh_eth_write(ndev, ndev->mtu + ETH_HLEN + ETH_FCS_LEN, RFLR);
>>
>=20
> No VLAN_HDR ?
>=20

Thank you for your point.
I forgot care of VLAN. I will add "+ VLAN_HLEN" and submit a patch.

Best regards,
Yoshihiro Shimoda
