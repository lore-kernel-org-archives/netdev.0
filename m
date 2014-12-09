From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink: use jhash as hashfn for rhashtable
Date: Tue, 09 Dec 2014 18:09:59 -0500 (EST)
Message-ID: <20141209.180959.500105903540817044.davem@davemloft.net>
References: <1418056230-8700-1-git-send-email-dborkman@redhat.com>
	<20141209.143829.477482216978677919.davem@davemloft.net>
	<54877E28.7020202@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au, tgraf@suug.ch,
	hannes@stressinduktion.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39823 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753762AbaLIXKC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 18:10:02 -0500
In-Reply-To: <54877E28.7020202@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue, 09 Dec 2014 23:56:40 +0100

> we thought it was useful in that area as it needs less than half the
> cycles (all discussed in [1]) as opposed to jhash for computing the
> hash value in ovs, where such computations are being done very
> frequently and the flow key structure size seems to keep growing.

If that is the case, you could instead come up with a portable C hash
function that doesn't require jumping through hoops to use special CPU
instructions yet still has the better performance you're looking for.

Heck, if attackability isn't an issue, plain ole 'xor' over the u32's
of the key is sufficient and in fact is what our TCP socket hash used
to be before jhash.

> Anyway, if you feel strong about it, lets just remove it.

Please do.
