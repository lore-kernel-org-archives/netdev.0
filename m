From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: [PATCH] net: xfrm_user: use BUG_ON instead of if condition
 followed by BUG
Date: Wed, 25 Oct 2017 19:38:35 -0500
Message-ID: <20171025193835.Horde.awZHiBVl04eXjKWA7saVTeB@gator4166.hostgator.com>
References: <20171024035320.GA29795@gondor.apana.org.au>
 <20171024.174842.272234711073180328.davem@davemloft.net>
 <20171025040541.GA1999@gondor.apana.org.au>
 <20171025.132222.1438740282932861791.davem@davemloft.net>
 <20171025072800.GQ3323@secunet.com>
 <20171025114351.Horde.MQ4XGlIueQ50FhD0JRZ9B-o@gator4166.hostgator.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171025114351.Horde.MQ4XGlIueQ50FhD0JRZ9B-o@gator4166.hostgator.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Quoting "Gustavo A. R. Silva" <garsilva@embeddedor.com>:

> Hi all,
>
> Quoting Steffen Klassert <steffen.klassert@secunet.com>:
>
>> On Wed, Oct 25, 2017 at 01:22:22PM +0900, David Miller wrote:
>>> From: Herbert Xu <herbert@gondor.apana.org.au>
>>> Date: Wed, 25 Oct 2017 12:05:41 +0800
>>>
>>>> On Tue, Oct 24, 2017 at 05:48:42PM +0900, David Miller wrote:
>>>>>
>>>>> This discussion has happened before.
>>>>>
>>>>> But I'll explain the conclusion here for your benefit.
>>>>>
>>>>> BUG_ON() is a statement and everything inside of it will
>>>>> always execute.
>>>>>
>>>>> BUG_ON() is always preferred because it allows arch
>>>>> specific code to pass the conditional result properly
>>>>> into inline asm and builtins for optimal code generation.
>>>>
>>>> This is a good point.  However, while a little bit more verbose you
>>>> can still achieve the same assembly-level result by something like
>>>>
>>>> 	int err;
>>>>
>>>> 	err = <insert real code here>;
>>>> 	BUG_ON(err);
>>>>
>>>> Having real code in BUG_ON may pose problems to people reading the
>>>> code because some of us tend to ignore code in BUG_ON and similar
>>>> macros such as BUILD_BUG_ON.
>>>
>>> I agree that this makes the code easier to read and audit.
>>
>> It seems that we have an agreement on the above version,
>> Gustavo can you please update your patches to this?
>>
>

By the way... this solution applies to the following sort of code:

if (xdr_buf_subsegment(buf, &integ_buf, 0, integ_len))
	BUG();

But what about the original code in this patch:

if (build_spdinfo(r_skb, net, sportid, seq, *flags) < 0)
	BUG();

I don't think we want something like:

bool err;

err = build_spdinfo(r_skb, net, sportid, seq, *flags) < 0 ? true : false;
BUG_ON(err);

Are you willing to accept the original patch in this case?

Thanks
--
Gustavo A. R. Silva
