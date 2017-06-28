From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] net: sched: Fix one possible panic when no
 destroy callback
Date: Tue, 27 Jun 2017 22:30:57 -0700
Message-ID: <1498627857.736.144.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1498625634-115351-1-git-send-email-gfree.wind@vip.163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        davem@davemloft.net, netdev@vger.kernel.org
To: gfree.wind@vip.163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36234 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751501AbdF1FbA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 01:31:00 -0400
Received: by mail-pg0-f68.google.com with SMTP id u36so6854865pgn.3
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 22:31:00 -0700 (PDT)
In-Reply-To: <1498625634-115351-1-git-send-email-gfree.wind@vip.163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-06-28 at 12:53 +0800, gfree.wind@vip.163.com wrote:
> From: Gao Feng <gfree.wind@vip.163.com>
> 
> When qdisc fail to init, qdisc_create would invoke the destroy callback
> to cleanup. But there is no check if the callback exists really. So it
> would cause the panic if there is no real destroy callback like the qdisc
> codel, fq, and so on.
> 
> Take codel as an example following:
> When a malicious user constructs one invalid netlink msg, it would cause
> codel_init->codel_change->nla_parse_nested failed.
> Then kernel would invoke the destroy callback directly but qdisc codel
> doesn't define one. It causes one panic as a result.
> 
> Now add one the check for destroy to avoid the possible panic.
> 
> Fixes: 87b60cfacf9f ("net_sched: fix error recovery at qdisc creation")
> Signed-off-by: Gao Feng <gfree.wind@vip.163.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
