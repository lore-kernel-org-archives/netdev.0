From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net/atm: warning in alloc_tx/__might_sleep
Date: Wed, 11 Jan 2017 11:18:52 +0100
Message-ID: <CAAeHK+xULc-jFCpdNZ4E5Qj3dezv75YS-Uyc9bt5cbrjCRyzLQ@mail.gmail.com>
References: <CAAeHK+yZ16SKcmJbv2ARafGgAuX2wwQNE0HGdiFy1WgqPjxLMg@mail.gmail.com>
 <CAM_iQpWaHX_orHbFjKcjBZL67b6LUAmOfvS1SQP13VPZDo-69w@mail.gmail.com> <CANn89iLxQPAt0e5Yc0yYFFQtoQwuRsdAwH9m1d4oqWQ3W=DZTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANn89iLxQPAt0e5Yc0yYFFQtoQwuRsdAwH9m1d4oqWQ3W=DZTQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 10, 2017 at 6:40 PM, Eric Dumazet <edumazet@google.com> wrote:
> On Tue, Jan 10, 2017 at 9:35 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> On Mon, Jan 9, 2017 at 9:20 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
>>
>> The fix should be straight-forward. Mind to try the attached patch?

Hi Cong,

Your patch with schedule() removed as suggested by Eric fixes the issue.

Tested-by: Andrey Konovalov <andreyknvl@google.com>

Thanks!

>
>
> You forgot to remove schedule() ?
>
>   schedule();
> + wait_woken(&wait, TASK_INTERRUPTIBLE, MAX_SCHEDULE_TIMEOUT);
