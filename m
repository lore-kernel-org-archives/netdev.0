From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net v2 1/4] net/sched: Change tc_action refcnt and bindcnt
 to atomic
Date: Tue, 17 Oct 2017 08:52:54 -0700
Message-ID: <CAM_iQpWbfjCH0EFb8RYnOuZQtVtg-Mw-Kzv3GWq81qTVErN6hA@mail.gmail.com>
References: <1508152718-28726-1-git-send-email-chrism@mellanox.com>
 <1508152718-28726-2-git-send-email-chrism@mellanox.com> <CAM_iQpXA5y8nqCRAxy-9VJTSf3Z7g-6pL1PL1omcwkZn1apFUw@mail.gmail.com>
 <VI1PR0501MB21439CB952C540F903969648AB4C0@VI1PR0501MB2143.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Lucas Bates <lucasb@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>,
        David Miller <davem@davemloft.net>
To: Chris Mi <chrism@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:53143 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965223AbdJQPxP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 11:53:15 -0400
Received: by mail-pg0-f66.google.com with SMTP id a192so1736411pge.9
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 08:53:14 -0700 (PDT)
In-Reply-To: <VI1PR0501MB21439CB952C540F903969648AB4C0@VI1PR0501MB2143.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 16, 2017 at 6:14 PM, Chris Mi <chrism@mellanox.com> wrote:
> I don't think this bug were introduced by above two commits only.
> Actually, this bug were introduced by several commits, at least the following:
> 1. refcnt and bindcnt are not atomic

Nope, it is perfectly okay with non-atomic as long as no parallel,
and without RCU callback they are perfectly serialized by RTNL.


> 2. passing actions using list instead of arrays (I think initially we are using arrays)

We are discussing patch 1/4, this is patch 2/4, so irrelevant.


> 3. using RCU callbacks

This introduces problem 1.


> So instead of blaming the latest commit, it is better to say it is a pre-git error.

You are wrong.
