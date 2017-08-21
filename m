From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] net_sched/hhf: update hierarchical backlog when drop packet
Date: Mon, 21 Aug 2017 10:03:08 -0700
Message-ID: <CAM_iQpV+XEnef522viC0xBLYJ+EzVJy_LHaDmSZJcUqczJcNuQ@mail.gmail.com>
References: <150330315167.155003.1998024290510727078.stgit@buzz>
 <CAM_iQpU4bQsNVHrooO1Mu_nmUvaD5WxQNmKiJBxOSmOtBBWvcQ@mail.gmail.com> <16531503334617@webcorp01h.yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Jiri Pirko <jiri@resnulli.us>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:34830 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753546AbdHURD3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 13:03:29 -0400
Received: by mail-pg0-f46.google.com with SMTP id u191so28854058pgc.2
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 10:03:29 -0700 (PDT)
In-Reply-To: <16531503334617@webcorp01h.yandex-team.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 21, 2017 at 9:56 AM, Konstantin Khlebnikov
<khlebnikov@yandex-team.ru> wrote:
> Current packet wouldn't be counted by parent either. So queue length isn't
> changed.
>

But the qdisc_tree_reduce_backlog() right below uses 1 too:


        /* As we dropped a packet, better let upper stack know this. */
        qdisc_tree_reduce_backlog(sch, 1, prev_backlog - sch->qstats.backlog);
        return NET_XMIT_SUCCESS;
