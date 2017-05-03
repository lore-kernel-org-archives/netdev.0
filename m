From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] netfilter: conntrack: Force inlining of build check to
 prevent build failure
Date: Wed, 3 May 2017 14:56:16 +0200
Message-ID: <CAK8P3a0yHsfYWbQjweZXUSNCWLL+V+7BZZai6AyGF3Ohav6wzA@mail.gmail.com>
References: <1493813923-5441-1-git-send-email-geert@linux-m68k.org>
 <CAK8P3a23oEo1zYdFD2nSFzvEc6SF_hoW+4OBig_SY3C1oHJA+g@mail.gmail.com> <CAMuHMdUxKE7cPVjg=1xyQ4nx=h5or2p2ZJk+xAkEOfK7fv3YYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        Florian Westphal <fw@strlen.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdUxKE7cPVjg=1xyQ4nx=h5or2p2ZJk+xAkEOfK7fv3YYw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 3, 2017 at 2:47 PM, Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> Hi Arnd,
>
> On Wed, May 3, 2017 at 2:32 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>> On Wed, May 3, 2017 at 2:18 PM, Geert Uytterhoeven <geert@linux-m68k.org> wrote:
>>> If gcc (e.g. 4.1.2) decides not to inline total_extension_size(), the
>>> build will fail with:
>>>
>>>     net/built-in.o: In function `nf_conntrack_init_start':
>>>     (.text+0x9baf6): undefined reference to `__compiletime_assert_1893'
>>>
>>> or
>>>
>>>     ERROR: "__compiletime_assert_1893" [net/netfilter/nf_conntrack.ko] undefined!
>>>
>>> Fix this by forcing inlining of total_extension_size().
>>>
>>> Fixes: b3a5db109e0670d6 ("netfilter: conntrack: use u8 for extension sizes again")
>>> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
>>
>> I saw this as well when I tried building with "gcc-7 -Og", and came to the same
>> conclusion.
>
> Good^H^H^H^HBad to see it not only happens with ancient compilers ;-)

Right now we don't see it on newer compilers (I assume gcc-4.3 or up) as we
always build with either -O2 or -Os optimizations. I was playing with -Og the
other day to get faster builds, but that causes many build failures
and additional
warnings as the result of missing out on optimizations that we have come
to rely on.

It might be worth getting -Og to build if the compile time is
drastically faster, but
we probably have to completely do away with BUILD_BUG_ON() and similar
checks in that configuration, which in turn makes the build output less
valuable.

       Arnd
