From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: [PATCH] can: fix warning in bcm_connect/proc_register
Date: Tue, 25 Oct 2016 14:12:57 +0200
Message-ID: <CAAeHK+yJA=h7znkP0s2pQbXif3+7rGSgtpOO0EaP3kW-JZGjeA@mail.gmail.com>
References: <20161024191126.30256-1-socketcan@hartkopp.net>
 <CAM_iQpXj3ktALCmjwaPKJuf0SDEc6Txk-yYkRzZ79LFEsxOx3w@mail.gmail.com> <CAM_iQpVmhH_9vQcTw+wP1qmPLOijZZrMZrq=_e4i5fUXYDON0Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
        David Miller <davem@davemloft.net>, linux-can@vger.kernel.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>,
        Kostya Serebryany <kcc@google.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpVmhH_9vQcTw+wP1qmPLOijZZrMZrq=_e4i5fUXYDON0Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Oliver,

I can confirm that your patch fixes the warnings for me.

Tested-by: Andrey Konovalov <andreyknvl@google.com>

On Mon, Oct 24, 2016 at 10:17 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Mon, Oct 24, 2016 at 1:10 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> On Mon, Oct 24, 2016 at 12:11 PM, Oliver Hartkopp
>> <socketcan@hartkopp.net> wrote:
>>>         if (proc_dir) {
>>>                 /* unique socket address as filename */
>>>                 sprintf(bo->procname, "%lu", sock_i_ino(sk));
>>>                 bo->bcm_proc_read = proc_create_data(bo->procname, 0644,
>>>                                                      proc_dir,
>>>                                                      &bcm_proc_fops, sk);
>>> +               if (!bo->bcm_proc_read) {
>>> +                       ret = -ENOMEM;
>>> +                       goto fail;
>>> +               }
>>
>> Well, I meant we need to call proc_create_data() once per socket,
>> so we need a check before proc_create_data() too.
>
> Hmm, bo->bound should guarantee it, so never mind, your patch
> looks fine.
