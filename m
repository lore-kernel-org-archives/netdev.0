From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 6/6] ipv6: Do route updating for redirect in ndisc
 layer
Date: Tue, 17 Sep 2013 20:29:36 -0400 (EDT)
Message-ID: <20130917.202936.2080212548361553334.davem@davemloft.net>
References: <52327F00.4040802@cn.fujitsu.com>
	<5232806B.6050601@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45230 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754066Ab3IRA3j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 20:29:39 -0400
In-Reply-To: <5232806B.6050601@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Fri, 13 Sep 2013 11:03:07 +0800

> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> 
> Do the whole verification and route updating in ndisc
> lay and then just call into icmpv6_notify() to notify
> the upper protocols.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

This is completely broken, and I believe your patch set fundamentally
is too.

We absolutely _must_ handle the redirect at the socket level when
we are able to, otherwise we cannot specify the mark properly and
the mark is an essential part of the key used to find the correct
route to work with.

I am not applying this patch series until you deal with this
deficiency.  I am not willing to consider changes which stop using the
more precise keying information available from a socket.
