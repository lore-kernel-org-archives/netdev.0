From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Fix ipv6 round-robin locking
Date: Wed, 28 Mar 2007 02:19:40 -0700 (PDT)
Message-ID: <20070328.021940.39154265.davem@davemloft.net>
References: <20070324.124436.104040932.davem@davemloft.net>
	<20070328.181642.47053702.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34671
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753637AbXC1JTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 05:19:41 -0400
In-Reply-To: <20070328.181642.47053702.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Wed, 28 Mar 2007 18:16:42 +0900 (JST)

> I hoped we could save some memory per fib6_node,
> but I'm fine with it.

I know, I did not want to add it either :(

Speaking of which, several of the potential fixes for the rt6_probe()
deadlock require adding even more things to the fib6_node (a linked
list which some workqueue or similar can run, or a timer, etc.).

So, I'm trying to figure out a way to get the rt6_probe() to run
outside of the per-table rwlock without adding more state to
fib6_node.
