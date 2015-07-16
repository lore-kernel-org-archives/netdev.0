From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] jhash: Deinline jhash, jhash2 and __jhash_nwords
Date: Thu, 16 Jul 2015 11:17:29 -0700 (PDT)
Message-ID: <20150716.111729.822179499552193763.davem@davemloft.net>
References: <1437050416-13295-1-git-send-email-dvlasenk@redhat.com>
	<CALx6S367jArRC3eKSKsv7gFrgPxyDHWdtvfeO1SmQR91eYxwSw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvlasenk@redhat.com, tgraf@suug.ch, alexander.h.duyck@redhat.com,
	kadlec@blackhole.kfki.hu, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tom@herbertland.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALx6S367jArRC3eKSKsv7gFrgPxyDHWdtvfeO1SmQR91eYxwSw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tom Herbert <tom@herbertland.com>
Date: Thu, 16 Jul 2015 08:43:25 -0700

> On Thu, Jul 16, 2015 at 5:40 AM, Denys Vlasenko <dvlasenk@redhat.com> wrote:
>> This patch deinlines jhash, jhash2 and __jhash_nwords.
>>
>> It also removes rhashtable_jhash2(key, length, seed)
>> because it was merely calling jhash2(key, length, seed).
>>
>> With this .config: http://busybox.net/~vda/kernel_config,
>> after deinlining these functions have sizes and callsite counts
>> as follows:
>>
>> __jhash_nwords: 72 bytes, 75 calls
>> jhash: 297 bytes, 111 calls
>> jhash2: 205 bytes, 136 calls
>>
> jhash is used in several places in the critical data path. Does the
> decrease in text size justify performance impact of not inlining it?

Tom took the words right out of my mouth.

Denys, you keep making deinlining changes like this all the time, like
a robot.  But I never see you make any effort to look into the performance
nor code generation ramifications of your changes.

And frankly that makes your patches quite tiring to deal with.

Your changes potentially have large performance implications, yet you
don't put any effort into considering that aspect at all.
