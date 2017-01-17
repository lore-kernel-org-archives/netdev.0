From: Kees Cook <keescook@google.com>
Subject: Re: sctp: kernel memory overwrite attempt detected in sctp_getsockopt_assoc_stats
Date: Tue, 17 Jan 2017 09:19:04 -0800
Message-ID: <CAGXu5jJoRbjDLydW--20ZA4bh_17ZyMx02tr=RhjWwhSkXpocQ@mail.gmail.com>
References: <CACT4Y+ZDPa+spEh6P_ip9=hsNfeZ8KJfwJu5jTrPKVkGJUaZSg@mail.gmail.com>
 <20170115203515.GA6274@neilslaptop.think-freely.org> <CACT4Y+Zp4cruuKtf7fkSeLFbYLzTOD79Y2c+cCrHx-pbEXC_6A@mail.gmail.com>
 <20170116135743.GC30105@hmswarspite.think-freely.org> <CACT4Y+aoRnZyPYM=Bz3RLWhK+MYrQJBZ22TijJd=fzHp9KG+9A@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DB0264AD2@AcuExch.aculab.com> <CACT4Y+bK3nvWoGJcZs5k1Lr3Rbn7ZxBCvNscs9Ty=7ZJEF37kQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Laight <David.Laight@aculab.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vladislav Yasevich <vyasevich@gmail.com>,
        David Miller <davem@davemloft.net>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>,
        Rik van Riel <riel@redhat.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+bK3nvWoGJcZs5k1Lr3Rbn7ZxBCvNscs9Ty=7ZJEF37kQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 16, 2017 at 6:56 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Mon, Jan 16, 2017 at 3:50 PM, David Laight <David.Laight@aculab.com> wrote:
>> From: Dmitry Vyukov
>>> Sent: 16 January 2017 14:04
>>> >> >> I've enabled CONFIG_HARDENED_USERCOPY_PAGESPAN on syzkaller fuzzer and
>> ...
>>> >> The code also takes into account compound pages. As far as I
>>> >> understand the intention of the check is to effectively find
>>> >> out-of-bounds copies (e.g. goes beyond the current heap allocation). I
>>> >> would expect that stacks are allocated as compound pages and don't
>>> >> trigger this check. I don't see it is firing in other similar places.
>>> >>
>>> > Honestly, I'm not overly familiar with stack page allocation, at least not so
>>> > far as compound vs. single page allocation is concerned.  I suppose the question
>>> > your really asking here is: Have you found a case in which the syscall fuzzer
>>> > has forced the allocation of an insecure non-compound page on the stack, or is
>>> > this a false positive warning.  I can't provide the answer to that.
>>>
>>> Yes. I added Kees, author of CONFIG_HARDENED_USERCOPY_PAGESPAN, to To line.
>>> Kees, is this a false positive?
>>
>> I'd guess that the kernel stack is (somehow) allocated page by page
>> rather than by a single multi-page allocate.
>> Or maybe vmalloc() isn't setting the required flag??
>
>
> Just in case, I don't have CONFIG_VMAP_STACK selected.
> If it is a generic issue, then CONFIG_HARDENED_USERCOPY_PAGESPAN looks
> considerably broken as there are tons of copies onto stack. I don't
> see what's special in this particular case.

There have been so many false positives on this option, even though it
is known not to be quite right, that I'll probably just remove it
entirely. It clearly needs much more work before it'll be useful, so
there's no reason to leave it in the kernel to confuse people. :)

-Kees

-- 
Kees Cook
Nexus Security
