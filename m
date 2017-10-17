From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net v3 2/4] net/sched: Use action array instead of action
 list as parameter
Date: Tue, 17 Oct 2017 09:55:38 -0700
Message-ID: <CAM_iQpUz4bKhb2uUiBBeXL6f6BfdAND7sW+az5MjbjbifRnmhw@mail.gmail.com>
References: <1508203218-17998-1-git-send-email-chrism@mellanox.com> <1508203218-17998-3-git-send-email-chrism@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Lucas Bates <lucasb@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>,
        David Miller <davem@davemloft.net>
To: Chris Mi <chrism@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:43627 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934082AbdJQQz7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 12:55:59 -0400
Received: by mail-pg0-f67.google.com with SMTP id s75so1891255pgs.0
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 09:55:59 -0700 (PDT)
In-Reply-To: <1508203218-17998-3-git-send-email-chrism@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 16, 2017 at 6:20 PM, Chris Mi <chrism@mellanox.com> wrote:
> When destroying filters, actions should be destroyed first.
> The pointers of each action are saved in an array. TC doesn't
> use the array directly, but put all actions in a doubly linked
> list and use that list as parameter.
>
> There is no problem if each filter has its own actions. But if
> some filters share the same action, when these filters are
> destroyed, RCU callback fl_destroy_filter() may be called at the
> same time. That means the same action's 'struct list_head list'
> could be manipulated at the same time. It may point to an invalid
> address so that system will panic.

So if we remove these RCU callbacks (by adding a sychronize_rcu)
this is not a problem, right? Or is there any other races than RCU
callbacks??


>
> This patch uses the action array directly to fix this issue.
>
> Fixes commit in pre-git era.
>
> Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")

This is wrong too. RCU callbacks were introduced very late.
