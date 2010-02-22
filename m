From: DDD <dongdong.deng@windriver.com>
Subject: Re: [PATCH] module param_call: fix potential NULL pointer dereference
Date: Mon, 22 Feb 2010 18:11:18 +0800
Message-ID: <4B825846.1030203@windriver.com>
References: <1266737078-26186-1-git-send-email-dongdong.deng@windriver.com> <2375c9f91002210041l1bf30871vdf3881589a654d5a@mail.gmail.com> <201002221941.21662.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-15?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jason.wessel@windriver.com,
	lenb@kernel.org, dwmw2@infradead.org,
	mdharm-usb@one-eyed-alien.net, bfields@fieldses.org,
	robert.richter@amd.com
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201002221941.21662.rusty@rustcorp.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rusty Russell wrote:
> On Sun, 21 Feb 2010 07:11:36 pm Am=E9rico Wang wrote:
>> On Sun, Feb 21, 2010 at 3:24 PM, Dongdong Deng
>> <dongdong.deng@windriver.com> wrote:
>>> The param_set_fn() function will get a parameter which is a NULL
>>> pointer when insmod module with params via following method:
>>>
>>> $insmod module.ko module_params
>>>
>>> BTW: the normal method usually as following format:
>>> $insmod module.ko module_params=3Dexample
>>>
>>> If the param_set_fn() function didn't check that parameter and used
>>> it directly, it could caused an OOPS due to NULL pointer dereferenc=
e.
>>>
>>> The solution is simple:
>>> Just checking the parameter before using in param_set_fn().
>>>
>>> Example:
>>> int set_module_params(const char *val, struct kernel_param *kp)
>>> {
>>>        /*Checking the val parameter before using */
>>>        if (!val)
>>>                return -EINVAL;
>>>        ...
>>> }
>>> module_param_call(module_params, set_module_params, NULL, NULL, 064=
4);
>>>
>> Why not just checking all of them in the generic code?
>=20
> It seemed useful to allow 'foo' as well as 'foo=3D'.=20

Ah, this is a good method to deal with this issue.

I will redo this patch shortly.

Thanks,
Dongdong

  But given these examples,
> obviously that was too easy to misuse.
>=20
> So I like your patch; please annotate it properly and put a comment
> like:
> 	/* We used to hand NULL for bare params, but most code didn't handle=
 it :( */
>=20
> I assume none of those non-standard param parsers *want* to handle NU=
LL?
>=20
> Thanks,
> Rusty.
