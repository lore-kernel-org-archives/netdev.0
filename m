From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 0/6] mv643xx_eth -next patches
Date: Tue, 18 Nov 2008 23:28:05 +0100
Message-ID: <20081118222805.GR5006@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:53416 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752503AbYKRW2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2008 17:28:08 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not too many changes this time round, as mv643xx_eth has converged
to a mostly sane state now, after the ~100 commits that went in
between 2.6.24 and 2.6.28.

The driver in 2.6.28-rc4 bears little resemblance to the one in 2.6.23:

$ wc linux-2.6.23/drivers/net/mv643xx_eth.c
 2773  9830 81901 drivers/net/mv643xx_eth.c
$ wc linux-2.6.28-rc4/drivers/net/mv643xx_eth.c
 2810  7569 67154 drivers/net/mv643xx_eth.c
$ git diff v2.6.23 v2.6.28-rc4 -- drivers/net/mv643xx_eth.c | diffstat
 mv643xx_eth.c | 4432 ++++++++++++++++++++++++++++------------------------------
 1 file changed, 2213 insertions(+), 2219 deletions(-)
$ 

The version in 28-rc4 is much cleaner, no longer comes with its own
hardware abstraction layer, got rid of its static variables, has support
for multiple instances, supports many more variants of the hardware
than the .23 version, fixed a couple of serious bugs, supports things
like multiqueue TX and phylib and skb recycling, all while shrinking by
about 20%.

In today's episode:
- Minor fixes to make checkpatch happy.
- Some more (small) performance improvements.
- Implement ->set_rx_mode() to deal with multiple unicast addresses
  (VLANs, DSA) without putting the interface into promiscuous mode.
