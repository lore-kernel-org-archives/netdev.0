From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] driver: vrf: Fix one possible use-after-free
 issue
Date: Thu, 11 May 2017 12:13:34 -0400 (EDT)
Message-ID: <20170511.121334.1892578973439125966.davem@davemloft.net>
References: <1494325653-39885-1-git-send-email-gfree.wind@vip.163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsa@cumulusnetworks.com, shm@cumulusnetworks.com, fw@strlen.de,
        netdev@vger.kernel.org
To: gfree.wind@vip.163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51720 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751825AbdEKQNg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 12:13:36 -0400
In-Reply-To: <1494325653-39885-1-git-send-email-gfree.wind@vip.163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: gfree.wind@vip.163.com
Date: Tue,  9 May 2017 18:27:33 +0800

> From: Gao Feng <gfree.wind@vip.163.com>
> 
> The current codes only deal with the case that the skb is dropped, it
> may meet one use-after-free issue when NF_HOOK returns 0 that means
> the skb is stolen by one netfilter rule or hook.
> 
> When one netfilter rule or hook stoles the skb and return NF_STOLEN,
> it means the skb is taken by the rule, and other modules should not
> touch this skb ever. Maybe the skb is queued or freed directly by the
> rule.
> 
> Now uses the nf_hook instead of NF_HOOK to get the result of netfilter,
> and check the return value of nf_hook. Only when its value equals 1, it
> means the skb could go ahead. Or reset the skb as NULL.
> 
> BTW, because vrf_rcv_finish is empty function, so needn't invoke it
> even though nf_hook returns 1. But we need to modify vrf_rcv_finish
> to deal with the NF_STOLEN case.
> 
> There are two cases when skb is stolen.
> 1. The skb is stolen and freed directly.
>    There is nothing we need to do, and vrf_rcv_finish isn't invoked.
> 2. The skb is queued and reinjected again.
>    The vrf_rcv_finish would be invoked as okfn, so need to free the
>    skb in it.
> 
> Signed-off-by: Gao Feng <gfree.wind@vip.163.com>

Applied and queued up for -stable, thanks.
