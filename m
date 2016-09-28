From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next] tcp: Change txhash on every SYN and RTO
 retransmit
Date: Wed, 28 Sep 2016 07:52:59 -0400 (EDT)
Message-ID: <20160928.075259.495409427572927438.davem@davemloft.net>
References: <20160928020337.3057238-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com, eric.dumazet@gmail.com,
        ycheng@google.com, ncardwell@google.com
To: brakmo@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33478 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752469AbcI1LxF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 07:53:05 -0400
In-Reply-To: <20160928020337.3057238-1-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lawrence Brakmo <brakmo@fb.com>
Date: Tue, 27 Sep 2016 19:03:37 -0700

> The current code changes txhash (flowlables) on every retransmitted
> SYN/ACK, but only after the 2nd retransmitted SYN and only after
> tcp_retries1 RTO retransmits.
> 
> With this patch:
> 1) txhash is changed with every SYN retransmits
> 2) txhash is changed with every RTO.
> 
> The result is that we can start re-routing around failed (or very
> congested paths) as soon as possible. Otherwise application health
> checks may fail and the connection may be terminated before we start
> to change txhash.
> 
> v4: Removed sysctl, txhash is changed for all RTOs
> v3: Removed text saying default value of sysctl is 0 (it is 100)
> v2: Added sysctl documentation and cleaned code
> 
> Tested with packetdrill tests
> 
> Signed-off-by: Lawrence Brakmo <brakmo@fb.com>

Applied, thanks.
