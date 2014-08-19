From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/2] cbq: incorrectly low bandwidth blocks
 limited traffic
Date: Tue, 19 Aug 2014 11:00:21 -0700 (PDT)
Message-ID: <20140819.110021.1713996150126013087.davem@davemloft.net>
References: <53EC72F1.5000501@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, eric.dumazet@gmail.com,
	kuznet@ms2.inr.ac.ru
To: vvs@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41280 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751940AbaHSSAG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2014 14:00:06 -0400
In-Reply-To: <53EC72F1.5000501@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasily Averin <vvs@parallels.com>
Date: Thu, 14 Aug 2014 12:27:29 +0400

> v2: patch description changes
> Fixes: f0f6ee1f70c4 ("cbq: incorrect processing of high limits")
> 
> Mainstream commit f0f6ee1f70c4 ("cbq: incorrect processing of high limits")
> have side effect: if cbq bandwidth setting is less than real interface
> throughput non-limited traffic can delay limited traffic for a very long time.
> 
> This happen because of q->now changes incorrectly in cbq_dequeue():
> in described scenario L2T is much greater than real time delay,
> and q->now gets an extra boost for each transmitted packet.
> 
> Accumulated boost prevents update q->now, and blocked class can wait
> very long time until (q->now >= cl->undertime) will be true again.
> 
> More detailed problem description can be found here:
> http://www.spinics.net/lists/netdev/msg292493.html
> 
> Following patches should fix the problem.

Series applied, thanks.
