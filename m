From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: fix TCP_SYNCNT flakes
Date: Wed, 24 May 2017 16:30:48 -0400 (EDT)
Message-ID: <20170524.163048.213785416977401052.davem@davemloft.net>
References: <1495568315.6465.71.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, soheil@google.com, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50046 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031184AbdEXUau (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 16:30:50 -0400
In-Reply-To: <1495568315.6465.71.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 23 May 2017 12:38:35 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> After the mentioned commit, some of our packetdrill tests became flaky.
> 
> TCP_SYNCNT socket option can limit the number of SYN retransmits.
> 
> retransmits_timed_out() has to compare times computations based on
> local_clock() while timers are based on jiffies. With NTP adjustments
> and roundings we can observe 999 ms delay for 1000 ms timers.
> We end up sending one extra SYN packet.
> 
> Gimmick added in commit 6fa12c850314 ("Revert Backoff [v3]: Calculate
> TCP's connection close threshold as a time value") makes no
> real sense for TCP_SYN_SENT sockets where no RTO backoff can happen at
> all.
> 
> Lets use a simpler logic for TCP_SYN_SENT sockets and remove @syn_set
> parameter from retransmits_timed_out()
> 
> Fixes: 9a568de4818d ("tcp: switch TCP TS option (RFC 7323) to 1ms clock")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Applied, thanks Eric.
