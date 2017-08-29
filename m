From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] sch_multiq: fix double free on init failure
Date: Tue, 29 Aug 2017 11:40:48 -0700
Message-ID: <1504032048.11498.85.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1504031188-11434-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, jiri@resnulli.us,
        roopa@cumulusnetworks.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:36199 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751186AbdH2Sku (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 14:40:50 -0400
Received: by mail-pg0-f44.google.com with SMTP id r133so13149358pgr.3
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 11:40:50 -0700 (PDT)
In-Reply-To: <1504031188-11434-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-08-29 at 21:26 +0300, Nikolay Aleksandrov wrote:
> The below commit added a call to ->destroy() on init failure, but multiq
> still frees ->queues on error in init, but ->queues is also freed by
> ->destroy() thus we get double free and corrupted memory.
> 
> Very easy to reproduce (eth0 not multiqueue):
> $ tc qdisc add dev eth0 root multiq
> RTNETLINK answers: Operation not supported
> $ ip l add dumdum type dummy
> (crash)

> Fixes: 87b60cfacf9f ("net_sched: fix error recovery at qdisc creation")
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
>  net/sched/sch_multiq.c | 3 ---
>  1 file changed, 3 deletions(-)
> 

Acked-by: Eric Dumazet <edumazet@google.com>
