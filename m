From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: RFC6298 supersedes RFC2988bis
Date: Sun, 15 Apr 2012 12:48:09 -0400 (EDT)
Message-ID: <20120415.124809.632477699748386101.davem@davemloft.net>
References: <1334296120.5300.8404.camel@edumazet-glaptop>
	<20120414.154724.636922650012404380.davem@davemloft.net>
	<1334504406.28012.17.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hkchu@google.com, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37332 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755653Ab2DOQsM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Apr 2012 12:48:12 -0400
In-Reply-To: <1334504406.28012.17.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 15 Apr 2012 17:40:06 +0200

> 3) use RCU and dont hold parent socket lock to allow parallelism for
> multiqueue NICS (or RPS ...)

This part could be tricky.

We have to be careful in the case that one cpu comes in and finds the
listner sock for a particular child, meanwhile another cpu progresses
that child socket into ESTABLISHED state.  Most of the parent locking
and strict synchronization is there to make sure this case works out
properly.
