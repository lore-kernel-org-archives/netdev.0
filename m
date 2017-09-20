From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] net_sched: always reset qdisc backlog in qdisc_reset()
Date: Wed, 20 Sep 2017 16:26:21 -0700
Message-ID: <CAM_iQpUQMtjnPpcACgFk0XOdMTeaOQFY4NcbW7Owd4rM1EMmNA@mail.gmail.com>
References: <150591153693.113604.8604505743746410801.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Jiri Pirko <jiri@resnulli.us>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:49683 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751813AbdITX0m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 19:26:42 -0400
Received: by mail-pf0-f180.google.com with SMTP id l188so2291496pfc.6
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 16:26:42 -0700 (PDT)
In-Reply-To: <150591153693.113604.8604505743746410801.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 20, 2017 at 5:45 AM, Konstantin Khlebnikov
<khlebnikov@yandex-team.ru> wrote:
> SKB stored in qdisc->gso_skb also counted into backlog.
>
> Some qdiscs don't reset backlog to zero in ->reset(),
> for example sfq just dequeue and free all queued skb.
>
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Fixes: 2ccccf5fb43f ("net_sched: update hierarchical backlog too")

Looks good.

sch->qstats.backlog = 0 can be removed from each ->reset()
after this patch.
