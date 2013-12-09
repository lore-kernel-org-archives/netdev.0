From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH net-next 2/3] xfrm: clamp down spi range for IPComp when
 allocating spi
Date: Mon, 9 Dec 2013 17:13:52 +0800
Message-ID: <52A589D0.4000802@windriver.com>
References: <1385607161-27597-1-git-send-email-fan.du@windriver.com> <1385607161-27597-3-git-send-email-fan.du@windriver.com> <20131206114248.GG31491@secunet.com> <52A562DF.4090302@windriver.com> <20131209085703.GJ31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53298 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932279Ab3LIJOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 04:14:05 -0500
In-Reply-To: <20131209085703.GJ31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B412=E6=9C=8809=E6=97=A5 16:57, Steffen Klassert wrote:
> On Mon, Dec 09, 2013 at 02:27:43PM +0800, Fan Du wrote:
>> On 2013=E5=B9=B412=E6=9C=8806=E6=97=A5 19:42, Steffen Klassert wrote=
:
>>>
>>> Also, the spi range is user defined, we should respect the
>>> users configuration if the range is valid.
>>
>> Ok, then, speaking of respect user defined range, how about below in=
formal
>> patch which only check the validity of the range? My original though=
ts is CPI
>> is only 16bits wide, kernel itself can keep the CPI's validity. btw,=
 v2 will
>> also fix patch1/3 align issue.
>>
>> diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
>> index 6a9c402..2c6fb99 100644
>> --- a/net/xfrm/xfrm_state.c
>> +++ b/net/xfrm/xfrm_state.c
>> @@ -1507,6 +1507,9 @@ int xfrm_alloc_spi(struct xfrm_state *x, u32 l=
ow, u32 high)
>>
>>          err =3D -ENOENT;
>>
>> +       if ((x->id.proto =3D=3D IPPROTO_COMP)&&  (high>  0xFFFF))
>> +               goto unlock;
>> +
>
> This check is already done in verify_userspi_info() if xfrm_alloc_spi=
()
> is called from xfrm_alloc_userspi().
>
> Instead of doing this check here again, we should implement an equiva=
lent
> to verify_userspi_info() for pfkey. Then we are sure to have a valid =
range
> in any case.
>

How about export an common function in xfrm_state.c to check this corne=
r case?
This could be shared by both netlink and pfkey interface, and verify_us=
erspi_info
simplified also?

int check_ipcomp_spirange(u8 proto, u32 high)
{
	if ((proto =3D=3D IPPROTO_COMP) && (high > 0xFFFF))
		return -EINVAL;
	else return 0;
}
EXPORT_SYMBOL(check_ipcomp_spirange);



--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
