From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] af-unix: passcred support for sendpage
Date: Mon, 30 Nov 2015 15:17:57 -0500 (EST)
Message-ID: <20151130.151757.498926843153934581.davem@davemloft.net>
References: <1448536098-8980-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
	edumazet@google.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33451 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751915AbbK3UR7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 15:17:59 -0500
In-Reply-To: <1448536098-8980-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 26 Nov 2015 12:08:18 +0100

> sendpage did not care about credentials at all. This could lead to
> situations in which because of fd passing between processes we could
> append data to skbs with different scm data. It is illegal to splice those
> skbs together. Instead we have to allocate a new skb and if requested
> fill out the scm details.
> 
> Fixes: 869e7c62486ec ("net: af_unix: implement stream sendpage support")
> Reported-by: Al Viro <viro@zeniv.linux.org.uk>
> Cc: Al Viro <viro@zeniv.linux.org.uk>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable... but here we go with even more
complexity in arguably one of the most complex and often buggiest
protocol family implementations :-/

We seem to enjoy self-torture but putting hack on top of hack...
