From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net-next v2 2/4] net/sched: Introduce sample tc action
Date: Mon, 30 Jan 2017 21:57:11 -0800
Message-ID: <CAM_iQpUK7OiQ0+521W+uoR-O8=BAO5=BU1oNkB7qTd8vo3B57A@mail.gmail.com>
References: <1485166031-4773-1-git-send-email-jiri@resnulli.us>
 <1485166031-4773-3-git-send-email-jiri@resnulli.us> <CAM_iQpUHrhkVtgrA37btQ9sn0UPeYgkqnRx=3HZoLan-soT8hg@mail.gmail.com>
 <DB3PR05MB0764257D27CD1EFA14207705AC4B0@DB3PR05MB0764.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Ido Schimmel <idosch@mellanox.com>,
        Elad Raz <eladr@mellanox.com>,
        Nogah Frankel <nogahf@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        "geert+renesas@glider.be" <geert+renesas@glider.be>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Guenter Roeck <linux@roeck-us.net>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Simon Horman <simon.horman@netronome.com>,
        Roman Mashak <mrv@mojatatu.com>
To: Yotam Gigi <yotamg@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34371 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751696AbdAaF6u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 00:58:50 -0500
Received: by mail-wm0-f67.google.com with SMTP id c85so81558176wmi.1
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 21:57:38 -0800 (PST)
In-Reply-To: <DB3PR05MB0764257D27CD1EFA14207705AC4B0@DB3PR05MB0764.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 30, 2017 at 8:49 AM, Yotam Gigi <yotamg@mellanox.com> wrote:
>
> Cong, after some thinking I think I don't really need the tcf_lock here. I
> don't really care if the truncate, trunc_size, rate and tcf_action are
> consistent among themselves - the only parameter that I care about is the
> psample_group pointer, and it is protected via RCU. As far as I see, there is
> no need to lock here.

OK, I trust you, you should know the logic better than me.

>
> I do need to take the tcf_lock to protect the statistics update in the
> tcf_sample_act code, as far as I see.
>

Hm? You use percpu stats, so you don't need spinlock.
