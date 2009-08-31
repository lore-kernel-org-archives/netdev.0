From: Stephen Hemminger <shemminger@vyatta.com>
Subject: neighbour table RCU
Date: Mon, 31 Aug 2009 15:04:53 -0700
Message-ID: <20090831150453.3437a65c@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49044 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751048AbZHaWE4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Aug 2009 18:04:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looking at the neighbour table, it should be possible to get
rid of the two reader/writer locks.  The hash table lock is pretty
amenable to RCU, but the dynamic resizing makes it non-trivial.
Thinking of using a combination of RCU and sequence counts so that the
reader would just rescan if resize was in progress.

The reader/writer lock on the neighbour entry is more of a problem.
Probably would be simpler/faster to change it into a spinlock and
be done with it.

The reader/writer lock is also used for the proxy list hash table,
but that can just be a simple spinlock.

-- 
