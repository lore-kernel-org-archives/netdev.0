From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Re: Re:Re: Re: [PATCH net] ppp: Fix a scheduling-while-atomic bug
 in del_chan
Date: Wed, 9 Aug 2017 11:18:44 -0700
Message-ID: <CAM_iQpU3hx-Y7OXTDWARFc08BE6qQ_cEjZb7ciVKrWPFh2j0JA@mail.gmail.com>
References: <1501495658-119725-1-git-send-email-gfree.wind@vip.163.com>
 <CAM_iQpVEsTpg17RZ1Y1jN2e0wb_X6gtxx05rmUSGa=A=XSj=Eg@mail.gmail.com>
 <CAM_iQpVta2EFVjutndCmoLBPWko7dgzP=Q1i2krPqyYuNBV4RA@mail.gmail.com>
 <31c9755c.ff6.15dba5238fc.Coremail.gfree.wind@vip.163.com>
 <CAM_iQpWmJmk=_yoV8=krOWonE_0orTC5Z4GaCnPg8Jv3GX6dmw@mail.gmail.com>
 <697dbbd.7911.15dbf5ca3a6.Coremail.gfree.wind@vip.163.com>
 <16ae6009.7a67.15dbf64b398.Coremail.gfree.wind@vip.163.com>
 <CAM_iQpW8W24=2atSyStwKPYJ9zmOO5XiznktT3V_3qn00R7r=Q@mail.gmail.com> <73e6ac77.45ea.15dc569d56a.Coremail.gfree.wind@vip.163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: xeb@mail.ru, David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Gao Feng <gfree.wind@vip.163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f170.google.com ([209.85.217.170]:38486 "EHLO
        mail-ua0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752653AbdHISTG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 14:19:06 -0400
Received: by mail-ua0-f170.google.com with SMTP id w45so31816648uac.5
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 11:19:06 -0700 (PDT)
In-Reply-To: <73e6ac77.45ea.15dc569d56a.Coremail.gfree.wind@vip.163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 8, 2017 at 10:13 PM, Gao Feng <gfree.wind@vip.163.com> wrote:
> Maybe I didn't show my explanation clearly.
> I think it won't happen as I mentioned in the last email.
> Because the pptp_release invokes the synchronize_rcu to make sure it, and actually there is no one which would invoke del_chan except pptp_release.
> It is guaranteed by that the pptp_release doesn't put the sock refcnt until complete all cleanup include marking sk_state as PPPOX_DEAD.
>
> In other words, even though the pptp_release is not the last user of this sock, the other one wouldn't invoke del_chan in pptp_sock_destruct.
> Because the condition "!(sk->sk_state & PPPOX_DEAD)" must be false.

Only if sock->sk is always non-NULL for pptp_release(), which
is what I am not sure. If you look at other ->release(), similar checks
are there too, so not just for pptp.

>
> As summary, the del_chan and pppox_unbind_sock in pptp_sock_destruct are unnecessary.
> And it even brings confusing.

Sorry, I can't draw any conclusion for this.
