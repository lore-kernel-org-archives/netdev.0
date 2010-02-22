From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] module param_call: fix potential NULL pointer dereference
Date: Mon, 22 Feb 2010 15:37:00 +0800
Message-ID: <2375c9f91002212337l543795d5ndb24173dd19e039e@mail.gmail.com>
References: <1266737078-26186-1-git-send-email-dongdong.deng@windriver.com>
	 <2375c9f91002210041l1bf30871vdf3881589a654d5a@mail.gmail.com>
	 <4B80FA08.8080304@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rusty@rustcorp.com.au, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jason.wessel@windriver.com, lenb@kernel.org, dwmw2@infradead.org,
	mdharm-usb@one-eyed-alien.net, bfields@fieldses.org,
	robert.richter@amd.com
To: DDD <dongdong.deng@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B80FA08.8080304@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 21, 2010 at 5:16 PM, DDD <dongdong.deng@windriver.com> wrot=
e:
> Am=C3=A9rico Wang wrote:
>>
>> On Sun, Feb 21, 2010 at 3:24 PM, Dongdong Deng
>> <dongdong.deng@windriver.com> wrote:
>>>
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
>>> =C2=A0 =C2=A0 =C2=A0 /*Checking the val parameter before using */
>>> =C2=A0 =C2=A0 =C2=A0 if (!val)
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EINVAL;
>>> =C2=A0 =C2=A0 =C2=A0 ...
>>> }
>>> module_param_call(module_params, set_module_params, NULL, NULL, 064=
4);
>>>
>>
>> Why not just checking all of them in the generic code?
>
> It is no problem that we check the params before invoking param_set_f=
n().
>
> But I trend to do the checking in param_set_*fn(), because we can off=
er some
> special prompt infos to user if we want and handle some special cases=
 like
> param_set_bool().
>

Yeah, I knew standard bool parameters can accept that,
the problem is that KPARAM_ISBOOL is not enough to
check if a parameter is bool or not. Probably we need
a new flag...

Thanks.
