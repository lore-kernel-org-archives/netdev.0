From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: Fix mem leak in rt6i_pcpu
Date: Tue, 05 Jul 2016 14:09:49 -0700 (PDT)
Message-ID: <20160705.140949.1356441872073525132.davem@davemloft.net>
References: <1467745823-1402823-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
	hannes@stressinduktion.org, pety@rusnet.ru
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42656 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755510AbcGEVJu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 17:09:50 -0400
In-Reply-To: <1467745823-1402823-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Tue, 5 Jul 2016 12:10:23 -0700

> It was first reported and reproduced by Petr (thanks!) in
> https://bugzilla.kernel.org/show_bug.cgi?id=119581
> 
> free_percpu(rt->rt6i_pcpu) used to always happen in ip6_dst_destroy().
> 
> However, after fixing a deadlock bug in
> commit 9c7370a166b4 ("ipv6: Fix a potential deadlock when creating pcpu rt"),
> free_percpu() is not called before setting non_pcpu_rt->rt6i_pcpu to NULL.
> 
> It is worth to note that rt6i_pcpu is protected by table->tb6_lock.
> 
> kmemleak somehow did not report it.  We nailed it down by
> observing the pcpu entries in /proc/vmallocinfo (first suggested
> by Hannes, thanks!).
> 
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> Fixes: 9c7370a166b4 ("ipv6: Fix a potential deadlock when creating pcpu rt")
> Reported-by: Petr Novopashenniy <pety@rusnet.ru>
> Tested-by: Petr Novopashenniy <pety@rusnet.ru>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: Petr Novopashenniy <pety@rusnet.ru>

Applied and queued up for -stable.
