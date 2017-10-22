From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: flowlabel: do not leave opt->tot_len with
 garbage
Date: Sun, 22 Oct 2017 03:23:44 +0100 (WEST)
Message-ID: <20171022.032344.624053890646394779.davem@davemloft.net>
References: <1508613983.30291.33.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57790 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751313AbdJVCXr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2017 22:23:47 -0400
In-Reply-To: <1508613983.30291.33.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 21 Oct 2017 12:26:23 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> When syzkaller team brought us a C repro for the crash [1] that
> had been reported many times in the past, I finally could find
> the root cause.
> 
> If FlowLabel info is merged by fl6_merge_options(), we leave
> part of the opt_space storage provided by udp/raw/l2tp with random value
> in opt_space.tot_len, unless a control message was provided at sendmsg()
> time.
> 
> Then ip6_setup_cork() would use this random value to perform a kzalloc()
> call. Undefined behavior and crashes.
> 
> Fix is to properly set tot_len in fl6_merge_options()
> 
> At the same time, we can also avoid consuming memory and cpu cycles
> to clear it, if every option is copied via a kmemdup(). This is the
> change in ip6_setup_cork().

Nice detective work.

Applied and queued up for -stable.
