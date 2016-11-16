From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] gro_cells: mark napi struct as not busy poll
 candidates
Date: Tue, 15 Nov 2016 22:29:13 -0500 (EST)
Message-ID: <20161115.222913.1393451169820102481.davem@davemloft.net>
References: <1479163571.8455.83.camel@edumazet-glaptop3.roam.corp.google.com>
        <1479164967.8455.87.camel@edumazet-glaptop3.roam.corp.google.com>
        <1479169722.8455.108.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, paulmck@linux.vnet.ibm.com,
        xiyou.wangcong@gmail.com, rolf.neugebauer@docker.com,
        netdev@vger.kernel.org, justin.cormack@docker.com,
        ian.campbell@docker.com, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35784 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754534AbcKPD3Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 22:29:16 -0500
In-Reply-To: <1479169722.8455.108.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 14 Nov 2016 16:28:42 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Rolf Neugebauer reported very long delays at netns dismantle.
> 
> Eric W. Biederman was kind enough to look at this problem
> and noticed synchronize_net() occurring from netif_napi_del() that was
> added in linux-4.5
> 
> Busy polling makes no sense for tunnels NAPI.
> If busy poll is used for sessions over tunnels, the poller will need to
> poll the physical device queue anyway.
> 
> netif_tx_napi_add() could be used here, but function name is misleading,
> and renaming it is not stable material, so set NAPI_STATE_NO_BUSY_POLL
> bit directly.
> 
> This will avoid inserting gro_cells napi structures in napi_hash[]
> and avoid the problematic synchronize_net() (per possible cpu) that
> Rolf reported.
> 
> Fixes: 93d05d4a320c ("net: provide generic busy polling to all NAPI drivers")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Rolf Neugebauer <rolf.neugebauer@docker.com>
> Reported-by: Eric W. Biederman <ebiederm@xmission.com>

Applied, thanks.
