From: David Miller <davem@davemloft.net>
Subject: inet_diag_dump_icsk() change seems bogus...
Date: Sun, 02 Feb 2014 00:45:38 -0800 (PST)
Message-ID: <20140202.004538.1011276314292086521.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52540 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751253AbaBBIpl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Feb 2014 03:45:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Upon further review, commit 70315d22d3c7383f9a508d0aab21e2eb35b2303a
("inet_diag: fix inet_diag_dump_icsk() to use correct state for
timewait sockets") doesn't seem valid to me.

Take a close look at get_tcp4_sock() and get_timewait4_sock() which
you reference in your commit message.

The former always gets it's socket from head->chain and the latter
always gets it's socket from head->twchain.

Yet in this inet_diag_dump_icsk() change, you're changing the
head->chain iterator to check for timewait sockets.  That doesn't
seem possible.

Only head->twchain holds timewait sockets, and this code was handling
it correctly already.

What gives?
