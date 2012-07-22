From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Sun, 22 Jul 2012 12:42:48 -0700 (PDT)
Message-ID: <20120722.124248.1156716792541498634.davem@davemloft.net>
References: <20120720.142502.1144557295933737451.davem@davemloft.net>
	<CAGK4HS_ZqH+std9Edbia7i1tdpLxpdsMD83fcTQPnNZbnX4zPA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: subramanian.vijay@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38173 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752430Ab2GVTmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2012 15:42:49 -0400
In-Reply-To: <CAGK4HS_ZqH+std9Edbia7i1tdpLxpdsMD83fcTQPnNZbnX4zPA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vijay Subramanian <subramanian.vijay@gmail.com>
Date: Sun, 22 Jul 2012 00:47:27 -0700

> I have been running your routing removal patches for the past 3 days
> (upgraded yesterday to latest set including the 17th patch you sent in
> response to Eric's comment) and have not seen any issues (crashes
> etc).

Thanks for testing.

> Apart from time spent in fib_table_lookup(), it seems time is also
> spent in check_leaf(). I assume this is expected behavior.
> Here are 2 sample perf outputs (I have appended the kbench outputs to
> each file)

Yes, the two biggest hogs will be fib_table_lookup() and check_leaf().

check_leaf() is expensive largely because that's where we write the
fib_result block, which is a structure on the fib_lookup() caller's
stack.

Your perf traces roughly approximate mine.

Thanks.
