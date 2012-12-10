From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 0/3 V4] net-tcp: TCP/IP stack bypass for
 loopback connections
Date: Mon, 10 Dec 2012 16:02:30 -0500 (EST)
Message-ID: <20121210.160230.1883556145617090938.davem@davemloft.net>
References: <CAEkNxbGTwGEBMCpSdib_paaxs0ekc52HWNo2Vai0nNSrZ1Zkng@mail.gmail.com>
	<cover.1354674151.git.wpan@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brutus@google.com
To: wpan@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59962 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291Ab2LJVCc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 16:02:32 -0500
In-Reply-To: <cover.1354674151.git.wpan@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weiping Pan <wpan@redhat.com>
Date: Wed,  5 Dec 2012 10:54:16 +0800

> Friends VS AF__UNIX
> Their call path are almost the same, but AF_UNIX uses its own send/recv codes
> with proper locks,
> so AF_UNIX's performance is much better than Friends.

While I understand the other portions of your analysis, this one
mystifies me.

In both cases, the sender has to queue the SKB onto the receiver's
queue.  And in both cases, the sender takes the lock on that queue.

So the locking contention really ought to be similar if not identical.

The only difference is that AF_UNIX takes the unix_sk()->lock of the
remote socket around these operations.

If that is enough of a synchronizer to "fix" the contention or reduce
it, then this would be very easy to test by adding a friend lock to
tcp_sk().
