From: Eric Dumazet <edumazet@google.com>
Subject: Re: net/atm: warning in alloc_tx/__might_sleep
Date: Tue, 10 Jan 2017 09:40:17 -0800
Message-ID: <CANn89iLxQPAt0e5Yc0yYFFQtoQwuRsdAwH9m1d4oqWQ3W=DZTQ@mail.gmail.com>
References: <CAAeHK+yZ16SKcmJbv2ARafGgAuX2wwQNE0HGdiFy1WgqPjxLMg@mail.gmail.com>
 <CAM_iQpWaHX_orHbFjKcjBZL67b6LUAmOfvS1SQP13VPZDo-69w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrey Konovalov <andreyknvl@google.com>,
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
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpWaHX_orHbFjKcjBZL67b6LUAmOfvS1SQP13VPZDo-69w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 10, 2017 at 9:35 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Mon, Jan 9, 2017 at 9:20 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
>
> The fix should be straight-forward. Mind to try the attached patch?


You forgot to remove schedule() ?

  schedule();
+ wait_woken(&wait, TASK_INTERRUPTIBLE, MAX_SCHEDULE_TIMEOUT);
