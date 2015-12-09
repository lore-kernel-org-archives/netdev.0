From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: avoid soft lockup in bnx2x_poll()
Date: Tue, 08 Dec 2015 22:55:27 -0500 (EST)
Message-ID: <20151208.225527.75074006409045414.davem@davemloft.net>
References: <1449582880.7632.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariel.elior@qlogic.com, willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49805 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751083AbbLIDz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 22:55:28 -0500
In-Reply-To: <1449582880.7632.19.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 08 Dec 2015 05:54:40 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Under heavy TX load, bnx2x_poll() can loop forever and trigger
> soft lockup bugs.
> 
> A napi poll handler must yield after one TX completion round,
> risk of livelock is too high otherwise.
> 
> Bug is very easy to trigger using a debug build, and udp flood, because
> of added cpu cycles in TX completion, and we do not receive enough
> packets to break the loop.
> 
> Reported-by: Willem de Bruijn <willemb@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Indeed, no driver should ever do more than one TX completion round
per NAPI poll call, _ever_.
