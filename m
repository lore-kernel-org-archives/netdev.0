From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: tcp_get_info() should read tcp_time_stamp
 later
Date: Thu, 16 Mar 2017 21:37:37 -0700 (PDT)
Message-ID: <20170316.213737.1012464455308900056.davem@davemloft.net>
References: <1489704199.28631.262.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56688 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751284AbdCQEhl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Mar 2017 00:37:41 -0400
In-Reply-To: <1489704199.28631.262.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 16 Mar 2017 15:43:19 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Commit b369e7fd41f7 ("tcp: make TCP_INFO more consistent") moved
> lock_sock_fast() earlier in tcp_get_info()
> 
> This has the minor effect that jiffies value being sampled at the
> beginning of tcp_get_info() is more likely to be off by one, and we
> report big tcpi_last_data_sent values (like 0xFFFFFFFF).
> 
> Since we lock the socket, fetching tcp_time_stamp right before
> doing the jiffies_to_msecs() calls is enough to remove these
> wrong values.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
