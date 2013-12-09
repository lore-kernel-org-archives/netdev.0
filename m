From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH net-next 2/3] xfrm: clamp down spi range for IPComp when
 allocating spi
Date: Mon, 9 Dec 2013 17:58:49 +0800
Message-ID: <52A59459.1010102@windriver.com>
References: <1385607161-27597-1-git-send-email-fan.du@windriver.com> <1385607161-27597-3-git-send-email-fan.du@windriver.com> <20131206114248.GG31491@secunet.com> <52A562DF.4090302@windriver.com> <20131209085703.GJ31491@secunet.com> <52A589D0.4000802@windriver.com> <20131209095133.GK31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:61128 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330Ab3LIJ7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 04:59:00 -0500
In-Reply-To: <20131209095133.GK31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B412=E6=9C=8809=E6=97=A5 17:51, Steffen Klassert wrote:
> On Mon, Dec 09, 2013 at 05:13:52PM +0800, Fan Du wrote:
>>
>>
>> On 2013=E5=B9=B412=E6=9C=8809=E6=97=A5 16:57, Steffen Klassert wrote=
:
>>>
>>> Instead of doing this check here again, we should implement an equi=
valent
>>> to verify_userspi_info() for pfkey. Then we are sure to have a vali=
d range
>>> in any case.
>>>
>>
>> How about export an common function in xfrm_state.c to check this co=
rner case?
>> This could be shared by both netlink and pfkey interface, and verify=
_userspi_info
>> simplified also?
>>
>> int check_ipcomp_spirange(u8 proto, u32 high)
>> {
>> 	if ((proto =3D=3D IPPROTO_COMP)&&  (high>  0xFFFF))
>> 		return -EINVAL;
>> 	else return 0;
>> }
>> EXPORT_SYMBOL(check_ipcomp_spirange);
>
> I don't think that we should export such a function,
> it is not sufficient.
>
> The netlink interface is ok, it does verify_userspi_info(),
> and the pfkey interface need all the checks done in
> verify_userspi_info() too. In particular the check if
> the minimum spi value is not bigger than the maximum.
>
> So we could either make verify_userspi_info() shared,

Ok, I will try to export verify_userspi_info then.
Is there any comments on patch3/3 before I make v2?

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
