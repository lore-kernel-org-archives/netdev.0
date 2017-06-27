From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net PATCH] net: sched: Fix one possible panic when no destroy callback
Date: Tue, 27 Jun 2017 10:08:02 -0700
Message-ID: <CAM_iQpUx8d_vQT=1d06Ah-d+E5R_10pnvcy4Y9ac_=txanPBOw@mail.gmail.com>
References: <1498527333-86838-1-git-send-email-gfree.wind@vip.163.com>
 <CAM_iQpXRy=cC2vuhju2Jf9=sJ+Yc6DvkzvFEU_DrRonyhW+E9w@mail.gmail.com> <1498582211.736.118.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: gfree.wind@vip.163.com, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33677 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751576AbdF0RIY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 13:08:24 -0400
Received: by mail-wm0-f66.google.com with SMTP id j85so6985747wmj.0
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 10:08:23 -0700 (PDT)
In-Reply-To: <1498582211.736.118.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 27, 2017 at 9:50 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2017-06-27 at 09:30 -0700, Cong Wang wrote:
>> On Mon, Jun 26, 2017 at 6:35 PM,  <gfree.wind@vip.163.com> wrote:
>> > From: Gao Feng <gfree.wind@vip.163.com>
>> >
>> > When qdisc fail to init, qdisc_create would invoke the destroy callback
>> > to cleanup. But there is no check if the callback exists really. So it
>> > would cause the panic if there is no real destroy callback like these
>> > qdisc codel, pfifo, pfifo_fast, and so on.
>> >
>> > Now add one the check for destroy to avoid the possible panic.
>> >
>> > Signed-off-by: Gao Feng <gfree.wind@vip.163.com>
>>
>> Looks good,
>>
>> Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
>>
>> This is introduced by commit 87b60cfacf9f17cf71933c6e33b.
>> Please add proper Fixes tag next time.
>
> Given that pfifo, pfifo_fast or codel can not fail their init,


How about codel_init() -> codel_change() -> nla_parse_nested() ?


> I do not see this patch as a net candidate, and the Fixes: tag seems not
> needed.


True, but we add Fixes tag to net-next candidates too.
