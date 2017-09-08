From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] netlink: access nlk groups safely in netlink bind and getname
Date: Fri, 8 Sep 2017 12:35:51 -0700
Message-ID: <CAM_iQpXA7q9_WADayWiHgqsz=VfhNqZr42TL0F+N2XK+toEEOQ@mail.gmail.com>
References: <cfb5c05d158b278beb2f1441c67a068a8bb27d44.1504670009.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: network dev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Florian Westphal <fw@strlen.de>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:34638 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756671AbdIHTgM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 15:36:12 -0400
Received: by mail-pg0-f44.google.com with SMTP id q68so6354772pgq.1
        for <netdev@vger.kernel.org>; Fri, 08 Sep 2017 12:36:12 -0700 (PDT)
In-Reply-To: <cfb5c05d158b278beb2f1441c67a068a8bb27d44.1504670009.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 5, 2017 at 8:53 PM, Xin Long <lucien.xin@gmail.com> wrote:
> Now there is no lock protecting nlk ngroups/groups' accessing in
> netlink bind and getname. It's safe from nlk groups' setting in
> netlink_release, but not from netlink_realloc_groups called by
> netlink_setsockopt.
>
> netlink_lock_table is needed in both netlink bind and getname when
> accessing nlk groups.

This looks very odd.

netlink_lock_table() should be protecting nl_table, why
it also protects nlk->groups?? For me it looks like you
need lock_sock() instead.
