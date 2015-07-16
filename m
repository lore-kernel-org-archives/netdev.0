From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2] jhash: Deinline jhash, jhash2 and __jhash_nwords
Date: Thu, 16 Jul 2015 12:23:31 -0700
Message-ID: <1437074611.2495.39.camel@perches.com>
References: <1437050416-13295-1-git-send-email-dvlasenk@redhat.com>
	 <CALx6S367jArRC3eKSKsv7gFrgPxyDHWdtvfeO1SmQR91eYxwSw@mail.gmail.com>
	 <20150716.111729.822179499552193763.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, dvlasenk@redhat.com, tgraf@suug.ch,
	alexander.h.duyck@redhat.com, kadlec@blackhole.kfki.hu,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150716.111729.822179499552193763.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-07-16 at 11:17 -0700, David Miller wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Thu, 16 Jul 2015 08:43:25 -0700
> 
> > On Thu, Jul 16, 2015 at 5:40 AM, Denys Vlasenko <dvlasenk@redhat.com> wrote:
> >> This patch deinlines jhash, jhash2 and __jhash_nwords.
> >>
> >> It also removes rhashtable_jhash2(key, length, seed)
> >> because it was merely calling jhash2(key, length, seed).
> >>
> >> With this .config: http://busybox.net/~vda/kernel_config,
> >> after deinlining these functions have sizes and callsite counts
> >> as follows:
> >>
> >> __jhash_nwords: 72 bytes, 75 calls
> >> jhash: 297 bytes, 111 calls
> >> jhash2: 205 bytes, 136 calls
> >>
> > jhash is used in several places in the critical data path. Does the
> > decrease in text size justify performance impact of not inlining it?
> 
> Tom took the words right out of my mouth.
> 
> Denys, you keep making deinlining changes like this all the time, like
> a robot.  But I never see you make any effort to look into the performance
> nor code generation ramifications of your changes.
> 
> And frankly that makes your patches quite tiring to deal with.
> 
> Your changes potentially have large performance implications, yet you
> don't put any effort into considering that aspect at all.

It might be useful to have these performance impacting
changes guarded by something like CONFIG_CC_OPTIMIZE_FOR_SIZE
with another static __always_inline __<func> and a function &
EXPORT_SYMBOL or just a static inline so that where code size
is critical it's uninlined.

Though even for tiny embedded uses, the additional code
complexity might not be worth it.
