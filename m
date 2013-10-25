From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netem: markov loss model transition fix
Date: Fri, 25 Oct 2013 19:04:09 -0400 (EDT)
Message-ID: <20131025.190409.1394476393722866643.davem@davemloft.net>
References: <1382477226-1869-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	edumazet@google.com, stefano.salsano@uniroma2.it,
	fabio.ludovici@yahoo.it
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35962 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751514Ab3JYXEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 19:04:11 -0400
In-Reply-To: <1382477226-1869-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Tue, 22 Oct 2013 23:27:06 +0200

> The transition from markov state "3 => lost packets within a burst
> period" to "1 => successfully transmitted packets within a gap period"
> has no *additional* loss event. The loss already happen for transition
> from 1 -> 3, this additional loss will make things go wild.
> 
> E.g. transition probabilities:
> 
> p13:   10%
> p31:  100%
> 
> Expected:
> 
> Ploss = p13 / (p13 + p31)
> Ploss = ~9.09%
> 
> ... but it isn't. Even worse: we get a double loss - each time.
> So simple don't return true to indicate loss, rather break and return
> false.
> 
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Stefano Salsano <stefano.salsano@uniroma2.it>
> Cc: Fabio Ludovici <fabio.ludovici@yahoo.it>
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>

Applied.
