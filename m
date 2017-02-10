From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] netlink: move nla_put_{u8,u16,u32} out of line
Date: Fri, 10 Feb 2017 14:24:58 +0100
Message-ID: <CAK8P3a2VvyUj6z10GuPCdR9YHMDazfq86TKF260=waKeD83csg@mail.gmail.com>
References: <20170208211843.2822208-1-arnd@arndb.de> <CAK8P3a1FLFG7NvTEPNQB6Gam2y7O3K+5T_cmQg-rOfT4TKNfnA@mail.gmail.com>
 <CACT4Y+bpoud4y2N0xkatG8N5we6+scqYhCZhvaXJSBQiVnznTQ@mail.gmail.com> <4145102.8mea7fgqQV@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        David Laight <David.Laight@aculab.com>,
        netdev <netdev@vger.kernel.org>,
        Johannes Berg <johannes.berg@intel.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Alexander Potapenko <glider@google.com>,
        kasan-dev <kasan-dev@googlegroups.com>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Alexey Dobriyan <adobriyan@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Thomas Graf <tgraf@suug.ch>,
        Eric Dumazet <edumazet@google.com>,
        LKML <linux-kernel@vger.kernel.org>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4145102.8mea7fgqQV@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 9, 2017 at 6:00 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> To reduce this risk, -fsanitize-address-use-after-scope is now split out
> into a separate Kconfig option, which cannot be selected at the same time
> as CONFIG_KASAN_INLINE, leading to stack frames that are smaller than 2
> kilobytes most of the time on x86_64. Now we can turn on the warning again
> that was disabled in commit 3f181b4 ("lib/Kconfig.debug: disable
> -Wframe-larger-than warnings with KASAN=y").
>
> The hope is that we can fix all code that still produces warnings, so far
> I have found four areas that are still affected (netlink, hisi-hns,
> dvb and tty/keyboard), and I have patches for all of them.

scratch that, my randconfig tests found too many remaining problems
with asan-stack=1 even when only one of CONFIG_KASAN_INLINE
and -fsanitize-address-use-after-scope is set.

I actually get results as bad as
fs/direct-io.c: In function 'do_direct_IO':
fs/direct-io.c:1057:1: error: the frame size of 7240 bytes is larger
than 2048 bytes [-Werror=frame-larger-than=]

with KASAN_OUTLINE=y and KASAN_EXTRA=n.

I need to investigate further to see if I can narrow it down to some
other configuration options.

       Arnd
