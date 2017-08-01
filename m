From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] ppp: Fix a scheduling-while-atomic bug in del_chan
Date: Tue, 1 Aug 2017 13:39:21 -0700
Message-ID: <CAM_iQpVEsTpg17RZ1Y1jN2e0wb_X6gtxx05rmUSGa=A=XSj=Eg@mail.gmail.com>
References: <1501495658-119725-1-git-send-email-gfree.wind@vip.163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: xeb@mail.ru, David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Gao Feng <gfree.wind@vip.163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35058 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752502AbdHAUjn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 16:39:43 -0400
Received: by mail-wm0-f67.google.com with SMTP id r77so4684987wmd.2
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 13:39:42 -0700 (PDT)
In-Reply-To: <1501495658-119725-1-git-send-email-gfree.wind@vip.163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 31, 2017 at 3:07 AM,  <gfree.wind@vip.163.com> wrote:
> From: Gao Feng <gfree.wind@vip.163.com>
>
> The PPTP set the pptp_sock_destruct as the sock's sk_destruct, it would
> trigger this bug when __sk_free is invoked in atomic context, because of
> the call path pptp_sock_destruct->del_chan->synchronize_rcu.
>
> Now move the synchronize_rcu to pptp_release from del_chan. This is the
> only one case which would free the sock and need the synchronize_rcu.

I don't understand the last part.

>From my understanding, this RCU is supposed to protect the pppox_sock
pointers in 'callid_sock' which could be NULL'ed in del_chan(). And the
pppox_sock is freed when the last refcnt is gone, that is, when sock
dctor is called. pptp_release() is ONLY called when the fd in user-space
is gone, not necessarily the last refcnt.
