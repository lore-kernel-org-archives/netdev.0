From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] jhash: Deinline jhash, jhash2 and __jhash_nwords
Date: Sun, 19 Jul 2015 11:40:45 -0700 (PDT)
Message-ID: <20150719.114045.240943295841151182.davem@davemloft.net>
References: <CALx6S367jArRC3eKSKsv7gFrgPxyDHWdtvfeO1SmQR91eYxwSw@mail.gmail.com>
	<20150716.111729.822179499552193763.davem@davemloft.net>
	<55ABBEED.2000707@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, tgraf@suug.ch, alexander.h.duyck@redhat.com,
	kadlec@blackhole.kfki.hu, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: dvlasenk@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55ABBEED.2000707@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Denys Vlasenko <dvlasenk@redhat.com>
Date: Sun, 19 Jul 2015 17:14:53 +0200

> On 07/16/2015 08:17 PM, David Miller wrote:
>> From: Tom Herbert <tom@herbertland.com>
>> Date: Thu, 16 Jul 2015 08:43:25 -0700
>> 
>>> On Thu, Jul 16, 2015 at 5:40 AM, Denys Vlasenko <dvlasenk@redhat.com> wrote:
>>>> This patch deinlines jhash, jhash2 and __jhash_nwords.
>>>>
>>>> It also removes rhashtable_jhash2(key, length, seed)
>>>> because it was merely calling jhash2(key, length, seed).
>>>>
>>>> With this .config: http://busybox.net/~vda/kernel_config,
>>>> after deinlining these functions have sizes and callsite counts
>>>> as follows:
>>>>
>>>> __jhash_nwords: 72 bytes, 75 calls
>>>> jhash: 297 bytes, 111 calls
>>>> jhash2: 205 bytes, 136 calls
>>>>
>>> jhash is used in several places in the critical data path. Does the
>>> decrease in text size justify performance impact of not inlining it?
>> 
>> Tom took the words right out of my mouth.
>> 
>> Denys, you keep making deinlining changes like this all the time, like
>> a robot.  But I never see you make any effort to look into the performance
>> nor code generation ramifications of your changes.
> 
> The performance impact of the call/ret pair on modern x86
> CPUs is only 5 cycles. To make a real difference in execution
> speed, the function has to be less than 100 bytes of code.

What performance metrics have you collected to assert that deinlining
doesn't matter?  What networking tests have you done which stress the
socket demux path?

You still aren't addressing any of my concerns.
