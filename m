From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 2/2] net sched actions: fix module auto-loading
Date: Wed, 11 Oct 2017 10:30:55 -0700
Message-ID: <CAM_iQpVxYJanWW5OWj_SKMsxG=NmndEWCj+kLSdP2NMz+cD9rA@mail.gmail.com>
References: <1507733430-17860-1-git-send-email-mrv@mojatatu.com> <1507733430-17860-3-git-send-email-mrv@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Roman Mashak <mrv@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:37327 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751994AbdJKRbQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 13:31:16 -0400
Received: by mail-pg0-f67.google.com with SMTP id o1so2627831pga.4
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 10:31:16 -0700 (PDT)
In-Reply-To: <1507733430-17860-3-git-send-email-mrv@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 11, 2017 at 7:50 AM, Roman Mashak <mrv@mojatatu.com> wrote:
> Macro __stringify_1() can stringify a macro argument, however IFE_META_*
> are enums, so they never expand, however request_module expects an integer
> in IFE module name, so as a result it always fails to auto-load.
>
> Fixes: ef6980b6becb ("introduce IFE action")
> Signed-off-by: Roman Mashak <mrv@mojatatu.com>

Good catch!

Alternatively, it seems we can also do this:

...
#define _IFE_META_PRIO 3

enum {
...
        IFE_META_PRIO = _IFE_META_PRIO,
...
};



#define MODULE_ALIAS_IFE_META(metan)   MODULE_ALIAS("ifemeta" ##_
__stringify_1(metan))

But it does _not_ look any better than yours.

So,

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
