From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: reinitialize MTU probing when setting MSS in a
 TCP repair
Date: Wed, 31 May 2017 12:29:48 -0400 (EDT)
Message-ID: <20170531.122948.1070989770678019987.davem@davemloft.net>
References: <c5033bad-805d-c3f6-3de4-38ab5d3d84e8@taghos.com.br>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, xemul@parallels.com
To: douglascs@taghos.com.br
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40600 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751141AbdEaQaE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 12:30:04 -0400
In-Reply-To: <c5033bad-805d-c3f6-3de4-38ab5d3d84e8@taghos.com.br>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Douglas Caetano dos Santos <douglascs@taghos.com.br>
Date: Fri, 26 May 2017 14:28:00 -0300

> From: Douglas Caetano dos Santos <douglascs@taghos.com.br>
> 
> MTU probing initialization occurred only at connect() and at SYN or
> SYN-ACK reception, but the former sets MSS to either the default or the
> user set value (through TCP_MAXSEG sockopt) and the latter never happens
> with repaired sockets.
> 
> The result was that, with MTU probing enabled and unless TCP_MAXSEG
> sockopt was used before connect(), probing would be stuck at
> tcp_base_mss value until tcp_probe_interval seconds have passed.
> 
> Signed-off-by: Douglas Caetano dos Santos <douglascs@taghos.com.br>

This seems fine to me, as long as you call tcp_mtup_init() after setting
the mss_clamp, whichy you are, everything should be alright.

Applied, thanks.
