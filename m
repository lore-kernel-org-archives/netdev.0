From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: when rearming RTO, if RTO time is in past
 then fire RTO ASAP
Date: Fri, 18 Aug 2017 16:08:20 -0700 (PDT)
Message-ID: <20170818.160820.1134182631606956474.davem@davemloft.net>
References: <20170816215336.30419-1-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, edumazet@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34582 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751852AbdHRXIV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 19:08:21 -0400
In-Reply-To: <20170816215336.30419-1-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Wed, 16 Aug 2017 17:53:36 -0400

> In some situations tcp_send_loss_probe() can realize that it's unable
> to send a loss probe (TLP), and falls back to calling tcp_rearm_rto()
> to schedule an RTO timer. In such cases, sometimes tcp_rearm_rto()
> realizes that the RTO was eligible to fire immediately or at some
> point in the past (delta_us <= 0). Previously in such cases
> tcp_rearm_rto() was scheduling such "overdue" RTOs to happen at now +
> icsk_rto, which caused needless delays of hundreds of milliseconds
> (and non-linear behavior that made reproducible testing
> difficult). This commit changes the logic to schedule "overdue" RTOs
> ASAP, rather than at now + icsk_rto.
> 
> Suggested-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied with Fixes: tag added and queued up for -stable, thanks Neal.
