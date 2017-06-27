From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net PATCH] net: sched: Fix one possible panic when no destroy
 callback
Date: Tue, 27 Jun 2017 09:50:11 -0700
Message-ID: <1498582211.736.118.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1498527333-86838-1-git-send-email-gfree.wind@vip.163.com>
         <CAM_iQpXRy=cC2vuhju2Jf9=sJ+Yc6DvkzvFEU_DrRonyhW+E9w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: gfree.wind@vip.163.com, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34307 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751658AbdF0QuN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 12:50:13 -0400
Received: by mail-pg0-f67.google.com with SMTP id j186so4953968pge.1
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 09:50:13 -0700 (PDT)
In-Reply-To: <CAM_iQpXRy=cC2vuhju2Jf9=sJ+Yc6DvkzvFEU_DrRonyhW+E9w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-06-27 at 09:30 -0700, Cong Wang wrote:
> On Mon, Jun 26, 2017 at 6:35 PM,  <gfree.wind@vip.163.com> wrote:
> > From: Gao Feng <gfree.wind@vip.163.com>
> >
> > When qdisc fail to init, qdisc_create would invoke the destroy callback
> > to cleanup. But there is no check if the callback exists really. So it
> > would cause the panic if there is no real destroy callback like these
> > qdisc codel, pfifo, pfifo_fast, and so on.
> >
> > Now add one the check for destroy to avoid the possible panic.
> >
> > Signed-off-by: Gao Feng <gfree.wind@vip.163.com>
> 
> Looks good,
> 
> Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
> 
> This is introduced by commit 87b60cfacf9f17cf71933c6e33b.
> Please add proper Fixes tag next time.

Given that pfifo, pfifo_fast or codel can not fail their init,
I do not see this patch as a net candidate, and the Fixes: tag seems not
needed.

Gao, have you really hit a bug, or is this patch some kind of cleanup or
prep work ?

If yes, please properly identify which packet scheduler had an issue.

Thanks.
