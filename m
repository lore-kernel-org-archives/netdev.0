From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] ipv6: sr: fix several BUGs when preemption is
 enabled
Date: Fri, 13 Jan 2017 12:30:52 -0500 (EST)
Message-ID: <20170113.123052.335826935080532600.davem@davemloft.net>
References: <1484253001-29677-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.lebrun@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51324 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750757AbdAMRhQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 12:37:16 -0500
In-Reply-To: <1484253001-29677-1-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lebrun <david.lebrun@uclouvain.be>
Date: Thu, 12 Jan 2017 21:30:01 +0100

> When CONFIG_PREEMPT=y, CONFIG_IPV6=m and CONFIG_SEG6_HMAC=y,
> seg6_hmac_init() is called during the initialization of the ipv6 module.
> This causes a subsequent call to smp_processor_id() with preemption
> enabled, resulting in the following trace.
 ...
> Moreover, dst_cache_* functions also call smp_processor_id(), generating
> a similar trace.
> 
> This patch uses raw_cpu_ptr() in seg6_hmac_init() rather than this_cpu_ptr()
> and disable preemption when using dst_cache_* functions.
> 
> Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>

Applied, thanks.
