From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 0/5,RFC] mv643xx_eth fixes for 2.6.27
Date: Sun, 24 Aug 2008 04:03:24 +0200
Message-ID: <20080824020324.GA8762@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dale Farnsworth <dale@farnsworth.org>,
	Nicolas Pitre <nico@cam.org>, akpm@osdl.org,
	Gerhard Bertelsmann <info@gerhard-bertelsmann.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:45059 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751063AbYHXCD1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 22:03:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The following five mv643xx_eth fixes for 2.6.27 since commit
6a55617ed5d1aa62b850de2cf66f5ede2eef4825:
  Linus Torvalds (1):
        Linux v2.6.27-rc4

are available in the git repository at:

  git://git.marvell.com/mv643xx_eth.git for-2.6.27
  http://git.marvell.com/?p=mv643xx_eth.git;a=summary

Lennert Buytenhek (5):
      mv643xx_eth: fix NAPI 'rotting packet' issue
      mv643xx_eth: fix double add_timer() on the receive oom timer
      mv643xx_eth: fix inconsistent lock semantics
      mv643xx_eth: fix NULL pointer dereference in rxq_process()
      mv643xx_eth: enforce multiple-of-8-bytes receive buffer size restriction

 drivers/net/mv643xx_eth.c |   33 +++++++++++++++++++--------------
 1 files changed, 19 insertions(+), 14 deletions(-)

The second patch should fix http://bugzilla.kernel.org/show_bug.cgi?id=11377
-- Gerhard, can you please test if it makes your problem go away?  (It
won't make the out of memory messages go away, but it should fix the
kernel panic.)

There is still one open report from a user of doing ip=1.2.3.4 on the
kernel command line causing the interface to come up in a nonfunctional
state in 2.6.27 (whereas the same thing worked in 2.6.26), which is
still being bisected.


thanks,
Lennert
