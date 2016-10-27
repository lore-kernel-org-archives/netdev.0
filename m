From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] can: fix warning in bcm_connect/proc_register
Date: Thu, 27 Oct 2016 09:28:05 -0700
Message-ID: <CAM_iQpUVB3g6gq9-RX0QAzM_ojOS0q+jq9n9objyFwyTHPAgkw@mail.gmail.com>
References: <20161024191126.30256-1-socketcan@hartkopp.net>
 <CAM_iQpXj3ktALCmjwaPKJuf0SDEc6Txk-yYkRzZ79LFEsxOx3w@mail.gmail.com>
 <CAM_iQpVmhH_9vQcTw+wP1qmPLOijZZrMZrq=_e4i5fUXYDON0Q@mail.gmail.com> <d76a80c3-cbd2-a286-82de-4c26e372de56@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
        Andrey Konovalov <andreyknvl@google.com>,
        David Miller <davem@davemloft.net>, linux-can@vger.kernel.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>,
        Kostya Serebryany <kcc@google.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:33249 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936449AbcJ0Q21 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 12:28:27 -0400
In-Reply-To: <d76a80c3-cbd2-a286-82de-4c26e372de56@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 27, 2016 at 1:45 AM, Marc Kleine-Budde <mkl@pengutronix.de> wrote:
> On 10/24/2016 10:17 PM, Cong Wang wrote:
>> On Mon, Oct 24, 2016 at 1:10 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>> On Mon, Oct 24, 2016 at 12:11 PM, Oliver Hartkopp
>>> <socketcan@hartkopp.net> wrote:
>>>>         if (proc_dir) {
>>>>                 /* unique socket address as filename */
>>>>                 sprintf(bo->procname, "%lu", sock_i_ino(sk));
>>>>                 bo->bcm_proc_read = proc_create_data(bo->procname, 0644,
>>>>                                                      proc_dir,
>>>>                                                      &bcm_proc_fops, sk);
>>>> +               if (!bo->bcm_proc_read) {
>>>> +                       ret = -ENOMEM;
>>>> +                       goto fail;
>>>> +               }
>>>
>>> Well, I meant we need to call proc_create_data() once per socket,
>>> so we need a check before proc_create_data() too.
>>
>> Hmm, bo->bound should guarantee it, so never mind, your patch
>> looks fine.
>
> Can I add your Acked-by?

Of course.

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>

Thanks.
