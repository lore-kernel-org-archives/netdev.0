From: Christoph Lameter <cl@linux.com>
Subject: Re: Network latency regressions from 2.6.22 to 2.6.29 (results with
 IRQ affinity)
Date: Mon, 20 Apr 2009 15:16:49 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904201510410.17816@qirst.com>
References: <49E78A79.6050604@cosmosbay.com> <49E78C1E.9060405@cosmosbay.com> <alpine.DEB.1.10.0904161555040.23632@qirst.com> <20090416.160002.09845606.davem@davemloft.net> <alpine.DEB.1.10.0904171238550.20049@qirst.com> <49EA2D7F.3080405@cosmosbay.com>
 <alpine.DEB.1.10.0904201305360.1585@qirst.com> <49ECB775.6030202@cosmosbay.com> <alpine.DEB.1.10.0904201410430.3361@qirst.com> <49ECC30A.9040501@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:38230 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755751AbZDTTZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 15:25:06 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 9BA3582C5EF
	for <netdev@vger.kernel.org>; Mon, 20 Apr 2009 15:35:24 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id jAuZOibhTb-z for <netdev@vger.kernel.org>;
	Mon, 20 Apr 2009 15:35:24 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id AADF982C5FE
	for <netdev@vger.kernel.org>; Mon, 20 Apr 2009 15:35:02 -0400 (EDT)
In-Reply-To: <49ECC30A.9040501@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 20 Apr 2009, Eric Dumazet wrote:

> Point is that even with tcpdump running, latencies are very good on 2.6.30-rc2, and were very good
> with 2.6.22. I see no significant increase/decrease...

Well okay that applies to your testing methodology but the statement that
you have shown that the regression that I reported does not exist is not
proven since you ran a different test.

> 1 us is time to access about 10 false shared cache lines.

That depends on the size of the system and the number of processors
contending for the cache line.

> 64 bit arches store less pointers/long per cache line.
> So a 64 bit kernel could be slower on this kind of workload in the general case (if several cpus play the game)

Right. But in practice I have also seen slight performance increases due
to the increased availability of memory and the avoidence of various 32
bit hacks (like highmem). Plus several recent subsystems seem to be
optimized for 64 bit like f.e. Infiniband.

I'd still like to see udpping results on your testing rigg to get another
datapoint. If the udpping results are not showing regressions on your
tests then there is likely a config issue at the core of the regression
that I am seeing here.
