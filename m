From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net PATCH] net: sched: Fix one possible panic when no destroy
 callback
Date: Tue, 27 Jun 2017 10:49:50 -0700
Message-ID: <1498585790.736.135.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1498527333-86838-1-git-send-email-gfree.wind@vip.163.com>
         <CAM_iQpXRy=cC2vuhju2Jf9=sJ+Yc6DvkzvFEU_DrRonyhW+E9w@mail.gmail.com>
         <1498582211.736.118.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpUx8d_vQT=1d06Ah-d+E5R_10pnvcy4Y9ac_=txanPBOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: gfree.wind@vip.163.com, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35085 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752359AbdF0Rtw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 13:49:52 -0400
Received: by mail-pg0-f68.google.com with SMTP id f127so5122148pgc.2
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 10:49:51 -0700 (PDT)
In-Reply-To: <CAM_iQpUx8d_vQT=1d06Ah-d+E5R_10pnvcy4Y9ac_=txanPBOw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-06-27 at 10:08 -0700, Cong Wang wrote:
> On Tue, Jun 27, 2017 at 9:50 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Tue, 2017-06-27 at 09:30 -0700, Cong Wang wrote:
> >> On Mon, Jun 26, 2017 at 6:35 PM,  <gfree.wind@vip.163.com> wrote:
> >> > From: Gao Feng <gfree.wind@vip.163.com>
> >> >
> >> > When qdisc fail to init, qdisc_create would invoke the destroy callback
> >> > to cleanup. But there is no check if the callback exists really. So it
> >> > would cause the panic if there is no real destroy callback like these
> >> > qdisc codel, pfifo, pfifo_fast, and so on.
> >> >
> >> > Now add one the check for destroy to avoid the possible panic.
> >> >
> >> > Signed-off-by: Gao Feng <gfree.wind@vip.163.com>
> >>
> >> Looks good,
> >>
> >> Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
> >>
> >> This is introduced by commit 87b60cfacf9f17cf71933c6e33b.
> >> Please add proper Fixes tag next time.
> >
> > Given that pfifo, pfifo_fast or codel can not fail their init,
> 
> 
> How about codel_init() -> codel_change() -> nla_parse_nested() ?


Yeah, with a malicious user space then (iproute2/tc is fine), codel
could be problematic.

pfifo and pfifo_fast can definitely not hit this bug.

changelog needs a bit of attention, even if the bug is real.

Thanks.
