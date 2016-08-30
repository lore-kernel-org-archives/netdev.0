From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 1/1] net_sched: Introduce skbmod action
Date: Tue, 30 Aug 2016 05:35:18 -0700
Message-ID: <1472560518.14381.291.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472386756-23085-1-git-send-email-jhs@emojatatu.com>
         <1472400467.14381.252.camel@edumazet-glaptop3.roam.corp.google.com>
         <b075631d-92cc-d016-3786-aaacb3d5c13a@mojatatu.com>
         <b117fac2-c73f-2d42-3843-52f9717224d9@mojatatu.com>
         <1472494817.14381.267.camel@edumazet-glaptop3.roam.corp.google.com>
         <2a6e36a6-f128-ba9d-4d69-90ff5383fb75@mojatatu.com>
         <68852282-b009-7b5b-6887-1630935b1913@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, daniel@iogearbox.net,
        xiyou.wangcong@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33313 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758071AbcH3MfV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 08:35:21 -0400
Received: by mail-pf0-f194.google.com with SMTP id i6so1121882pfe.0
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 05:35:20 -0700 (PDT)
In-Reply-To: <68852282-b009-7b5b-6887-1630935b1913@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-08-30 at 07:57 -0400, Jamal Hadi Salim wrote:
>         rcu_assign_pointer(d->skbmod_p, p);
>         if (ovr) {
>                 spin_unlock_bh(&d->tcf_lock);
>                 synchronize_rcu();
>         }
> 
>         kfree(p_old);

Overall patch looks good Jamal, thanks.


synchronize_rcu() might bee to expensive if you plan to change actions
hundred of times per second.

You could instead add a 'struct rcu_head rcu;'  field in struct
tcf_skbmod_params  (but make sure this is not exported to user space)

Then :

        if (ovr)
                 spin_unlock_bh(&d->tcf_lock);
         kfree_rcu(p_old, rcu);
