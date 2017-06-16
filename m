From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 11/11] kasan: rework Kconfig settings
Date: Fri, 16 Jun 2017 13:42:05 +0200
Message-ID: <CAK8P3a18fdnNNSMdxCG13LTFQwQgYmr9ZiBp_r86M5KyFKFqHA@mail.gmail.com>
References: <20170614211556.2062728-1-arnd@arndb.de> <20170614211556.2062728-12-arnd@arndb.de>
 <CACT4Y+aNMBbkb8b+wwrdhVVxH-1NwgUm+vwXqUggmLnGK-8Q4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Andrew Morton <akpm@linux-foundation.org>,
        kasan-dev <kasan-dev@googlegroups.com>,
        Alexander Potapenko <glider@google.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Michal Marek <mmarek@suse.com>,
        Kees Cook <keescook@chromium.org>,
        Ingo Molnar <mingo@kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+aNMBbkb8b+wwrdhVVxH-1NwgUm+vwXqUggmLnGK-8Q4w@mail.gmail.com>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 15, 2017 at 9:02 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Wed, Jun 14, 2017 at 11:15 PM, Arnd Bergmann <arnd@arndb.de> wrote:

>> diff --git a/lib/Kconfig.kmemcheck b/lib/Kconfig.kmemcheck
>> index 846e039a86b4..58b9f3f81dc8 100644
>> --- a/lib/Kconfig.kmemcheck
>> +++ b/lib/Kconfig.kmemcheck
>> @@ -7,6 +7,7 @@ menuconfig KMEMCHECK
>>         bool "kmemcheck: trap use of uninitialized memory"
>>         depends on DEBUG_KERNEL
>>         depends on !X86_USE_3DNOW
>> +       depends on !KASAN_EXTRA
>
>
> KASAN is not meant to work with KMEMCHECK. I am not sure if it even
> works, and it's definitely unmaintained. Even if it works now, I am
> not sure what could be the intention of somebody running that
> combination.
> So I think we should do: depends on !KASAN
> Will it make things simper for you?

I don't think it will change anything for me, other than having to respin the
patch series or adding a patch on top.

I have just checked that KMEMCHECK is already disabled in allmodconfig,
and all but one of the warnings I address in the series show up in
allmodconfig too.

      Arnd
