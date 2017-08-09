From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 1/1] driver: pptp: Remove unnecessary statements
 in pptp_sock_destruct
Date: Wed, 9 Aug 2017 11:08:30 -0700
Message-ID: <CAM_iQpUXRV6DamR_U1_bvBUBOk6SQ6jF3xLKBpVZrjYE74LXiw@mail.gmail.com>
References: <1502294276-20051-1-git-send-email-gfree.wind@vip.163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: xeb@mail.ru, David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Gao Feng <gfree.wind@vip.163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f65.google.com ([209.85.213.65]:33192 "EHLO
        mail-vk0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752402AbdHISIv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 14:08:51 -0400
Received: by mail-vk0-f65.google.com with SMTP id g189so4066843vke.0
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 11:08:51 -0700 (PDT)
In-Reply-To: <1502294276-20051-1-git-send-email-gfree.wind@vip.163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 9, 2017 at 8:57 AM,  <gfree.wind@vip.163.com> wrote:
> From: Gao Feng <gfree.wind@vip.163.com>
>
> In the commit ddab82821fa6 ("ppp: Fix a scheduling-while-atomic bug in
> del_chan"), I moved the synchronize_rcu() from del_chan() to pptp_release
> after del_chan() to avoid one scheduling-while-atomic bug.
>
> Actually the del_chan() and pppox_unbind_sock are unneccessary in the
> pptp_sock_destruct. Because the pptp sock refcnt wouldn't reach zero until
> sk_state is set as PPPOX_DEAD in pptp_release. By that time, the del_chan()
> and pppox_unbind_sock() have been invoked already and the condition check
> "!(sk->sk_state & PPPOX_DEAD)" of this sock must be false in pptp_sock_destruct.

I am not sure. The check for sock->sk in the beginning of pptp_release()
indicates there could be a case we could skip del_chan() in pptp_release(),
although I can't figure out how.

Also there is a suspicious sock_put() in pptp_release().
