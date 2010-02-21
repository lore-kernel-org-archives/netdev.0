From: DDD <dongdong.deng@windriver.com>
Subject: Re: [PATCH] module param_call: fix potential NULL pointer dereference
Date: Sun, 21 Feb 2010 17:16:56 +0800
Message-ID: <4B80FA08.8080304@windriver.com>
References: <1266737078-26186-1-git-send-email-dongdong.deng@windriver.com> <2375c9f91002210041l1bf30871vdf3881589a654d5a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rusty@rustcorp.com.au, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jason.wessel@windriver.com, lenb@kernel.org, dwmw2@infradead.org,
	mdharm-usb@one-eyed-alien.net, bfields@fieldses.org,
	robert.richter@amd.com
To: =?UTF-8?B?QW3DqXJpY28gV2FuZw==?= <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:40436 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754173Ab0BUJL1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2010 04:11:27 -0500
In-Reply-To: <2375c9f91002210041l1bf30871vdf3881589a654d5a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am=C3=A9rico Wang wrote:
> On Sun, Feb 21, 2010 at 3:24 PM, Dongdong Deng
> <dongdong.deng@windriver.com> wrote:
>> The param_set_fn() function will get a parameter which is a NULL
>> pointer when insmod module with params via following method:
>>
>> $insmod module.ko module_params
>>
>> BTW: the normal method usually as following format:
>> $insmod module.ko module_params=3Dexample
>>
>> If the param_set_fn() function didn't check that parameter and used
>> it directly, it could caused an OOPS due to NULL pointer dereference=
=2E
>>
>> The solution is simple:
>> Just checking the parameter before using in param_set_fn().
>>
>> Example:
>> int set_module_params(const char *val, struct kernel_param *kp)
>> {
>>        /*Checking the val parameter before using */
>>        if (!val)
>>                return -EINVAL;
>>        ...
>> }
>> module_param_call(module_params, set_module_params, NULL, NULL, 0644=
);
>>
>=20
> Why not just checking all of them in the generic code?

It is no problem that we check the params before invoking param_set_fn(=
).

But I trend to do the checking in param_set_*fn(), because we can offer=
=20
some special prompt infos to user if we want and handle some special=20
cases like param_set_bool().

Thanks,
Dongdong


> How about my _untested_ patch below?
>=20
> Thanks.
>=20
> -----------
>=20
> When a module parameter "foo" is not bool,=20

we shouldn't accept arguments
> like this "insmod ./foo.ko foo". However, currently only standard
> ->set functions
> check this, several non-standard ->set functions ignore this, thus co=
uld cause
> NULL def oops.
>=20
> Reported-by: Dongdong Deng <dongdong.deng@windriver.com>
> Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>
>=20
> ---
>=20

