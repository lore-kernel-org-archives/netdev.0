From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v4] tcp: warn on bogus MSS and try to amend it
Date: Tue, 06 Dec 2016 11:01:40 -0500 (EST)
Message-ID: <20161206.110140.1700034264770453023.davem@davemloft.net>
References: <2056cf96b896aa473ff017b9f223904a14bfed86.1480969929.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jmaxwell37@gmail.com,
        alexandre.sidorenko@hpe.com, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        tlfalcon@linux.vnet.ibm.com, brking@linux.vnet.ibm.com,
        eric.dumazet@gmail.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42520 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752638AbcLFQB6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 11:01:58 -0500
In-Reply-To: <2056cf96b896aa473ff017b9f223904a14bfed86.1480969929.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Mon,  5 Dec 2016 18:37:13 -0200

> There have been some reports lately about TCP connection stalls caused
> by NIC drivers that aren't setting gso_size on aggregated packets on rx
> path. This causes TCP to assume that the MSS is actually the size of the
> aggregated packet, which is invalid.
> 
> Although the proper fix is to be done at each driver, it's often hard
> and cumbersome for one to debug, come to such root cause and report/fix
> it.
> 
> This patch amends this situation in two ways. First, it adds a warning
> on when this situation occurs, so it gives a hint to those trying to
> debug this. It also limit the maximum probed MSS to the adverised MSS,
> as it should never be any higher than that.
> 
> The result is that the connection may not have the best performance ever
> but it shouldn't stall, and the admin will have a hint on what to look
> for.
> 
> Tested with virtio by forcing gso_size to 0.
> 
> v2: updated msg per David's suggestion
> v3: use skb_iif to find the interface and also log its name, per Eric
>     Dumazet's suggestion. As the skb may be backlogged and the interface
>     gone by then, we need to check if the number still has a meaning.
> v4: use helper tcp_gro_dev_warn() and avoid pr_warn_once inside __once, per
>     David's suggestion
> 
> Cc: Jonathan Maxwell <jmaxwell37@gmail.com>
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied, thanks Marcelo.
