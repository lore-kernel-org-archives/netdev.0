From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH v2] jhash: Deinline jhash, jhash2 and __jhash_nwords
Date: Fri, 17 Jul 2015 15:44:45 +0200 (CEST)
Message-ID: <2035533471.2349.1437140685694.JavaMail.open-xchange@ox1app>
References: <1437050416-13295-1-git-send-email-dvlasenk@redhat.com> <CALx6S367jArRC3eKSKsv7gFrgPxyDHWdtvfeO1SmQR91eYxwSw@mail.gmail.com> <20150716.111729.822179499552193763.davem@davemloft.net> <1437074611.2495.39.camel@perches.com>
Reply-To: Hagen Paul Pfeifer <hagen@jauu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: tom <tom@herbertland.com>, herbert <herbert@gondor.apana.org.au>,
	tgraf <tgraf@suug.ch>, netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	dvlasenk <dvlasenk@redhat.com>,
	"alexander.h.duyck" <alexander.h.duyck@redhat.com>,
	kadlec <kadlec@blackhole.kfki.hu>
To: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437074611.2495.39.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On July 16, 2015 at 9:23 PM Joe Perches <joe@perches.com> wrote:
> 
> It might be useful to have these performance impacting
> changes guarded by something like CONFIG_CC_OPTIMIZE_FOR_SIZE
> with another static __always_inline __<func> and a function &
> EXPORT_SYMBOL or just a static inline so that where code size
> is critical it's uninlined.

But keep in mind that jhash, jhash2 and __jhash_nwords are *not*
one-instruction long functions. We duplicate code over and over resulting
probably in more cache misses. __always_inline__ is probably too strict
and a vanilla inline is already for 99% of all distribution builds a
 __always_inline__, see ARCH_SUPPORTS_OPTIMIZED_INLINING and
CONFIG_CC_OPTIMIZE_FOR_SIZE.

The answer depends on the specific workload. Sometimes an enforced inline
perform better and sometimes a call is the better solution (read: less
cache misses). General purpose vendors with a larger working set size
should reduce cache misses by deinline many functions. For
high-performance special fast-path operations a strong inlined kernel
build is probably faster. __always_inline__ makes it impossible for the
user to deinline functions or not.

Hagen
