From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched: reset pointers to tcf blocks in classful
 qdiscs' destructors
Date: Tue, 15 Aug 2017 17:16:55 -0700 (PDT)
Message-ID: <20170815.171655.845249059396512148.davem@davemloft.net>
References: <150280412126.717517.16274927544808177918.stgit@buzz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
        jiri@mellanox.com, jhs@mojatatu.com
To: khlebnikov@yandex-team.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44042 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751460AbdHPAQ4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 20:16:56 -0400
In-Reply-To: <150280412126.717517.16274927544808177918.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Tue, 15 Aug 2017 16:35:21 +0300

> Traffic filters could keep direct pointers to classes in classful qdisc,
> thus qdisc destruction first removes all filters before freeing classes.
> Class destruction methods also tries to free attached filters but now
> this isn't safe because tcf_block_put() unlike to tcf_destroy_chain()
> cannot be called second time.
> 
> This patch set class->block to NULL after first tcf_block_put() and
> turn second call into no-op.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Fixes: 6529eaba33f0 ("net: sched: introduce tcf block infractructure")

Applied and queued up for -stable.
