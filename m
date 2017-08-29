From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] sch_multiq: fix double free on init failure
Date: Tue, 29 Aug 2017 11:59:45 -0700
Message-ID: <CAM_iQpVm0EvXsdcsAR546urmqgkeVgVqhJu=GwgWAhOutjzgyw@mail.gmail.com>
References: <1504031188-11434-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:35761 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751186AbdH2TAG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 15:00:06 -0400
Received: by mail-pg0-f51.google.com with SMTP id 63so13275183pgc.2
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 12:00:06 -0700 (PDT)
In-Reply-To: <1504031188-11434-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 29, 2017 at 11:26 AM, Nikolay Aleksandrov
<nikolay@cumulusnetworks.com> wrote:
> diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
> index f143b7bbaa0d..b07f8b01aa07 100644
> --- a/net/sched/sch_multiq.c
> +++ b/net/sched/sch_multiq.c
> @@ -259,9 +259,6 @@ static int multiq_init(struct Qdisc *sch, struct nlattr *opt)
>
>         err = multiq_tune(sch, opt);
>
> -       if (err)
> -               kfree(q->queues);
> -
>         return err;

You can fold them to:

    return multiq_tune(sch, opt);

Other than this,

Acked-by : Cong Wang <xiyou.wangcong@gmail.com>
