From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/10] tcp: do not use tcp_time_stamp for rcv
 autotuning
Date: Wed, 26 Apr 2017 14:44:58 -0400 (EDT)
Message-ID: <20170426.144458.2055504829054846592.davem@davemloft.net>
References: <20170425171541.3417-1-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, soheil@google.com, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59318 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965275AbdDZSpB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 14:45:01 -0400
In-Reply-To: <20170425171541.3417-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Tue, 25 Apr 2017 10:15:31 -0700

> Some devices or linux distributions use HZ=100 or HZ=250
> 
> TCP receive buffer autotuning has poor behavior caused by this choice.
> Since autotuning happens after 4 ms or 10 ms, short distance flows
> get their receive buffer tuned to a very high value, but after an initial
> period where it was frozen to (too small) initial value.
> 
> With BBR (or other CC allowing to increase BDP), we are willing to
> increase tcp_rmem[2], but this receive autotuning defect is a blocker
> for hosts dealing with gazillions of TCP flows in the data centers,
> since many of them have inflated RCVBUF. Risk of OOM is too high.
> 
> Note that TSO autodefer, tcp cubic, and TCP TS options (RFC 7323)
> also suffer from our dependency to jiffies (via tcp_time_stamp).
> 
> We have ongoing efforts to improve all that in the future.

Looks great, series applied, thanks Eric.
