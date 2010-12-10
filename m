From: Ben Hutchings <bhutchings@solarflare.com>
Subject: pull request: sfc-next-2.6 2010-12-10
Date: Fri, 10 Dec 2010 17:35:27 +0000
Message-ID: <1292002527.11673.14.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	sf-linux-drivers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:26569 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197Ab0LJRfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 12:35:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit defb3519a64141608725e2dac5a5aa9a3c644bae:

  net: Abstract away all dst_entry metrics accesses. (2010-12-09 10:46:36 -0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next-2.6.git for-davem

These changes include the 'TX push' feature I mentioned at netconf.
When an TX queue is empty this feature allows the driver to write the
next DMA descriptor directly to the NIC, reducing latency by about 0.5
us (dependent on the system).

Ben.

Ben Hutchings (10):
      sfc: Reorder struct efx_nic to separate fields by volatility
      sfc: Use ACCESS_ONCE when copying efx_tx_queue::read_count
      sfc: Expand/correct comments on collector behaviour and function usage
      sfc: Remove redundant memory barriers between MMIOs
      sfc: Add compile-time checks for correctness of paged register writes
      sfc: Remove locking from implementation of efx_writeo_paged()
      sfc: Use TX push whenever adding descriptors to an empty queue
      sfc: Log start and end of ethtool self-test at INFO level
      sfc: Remove filter table IDs from filter functions
      sfc: Generalise filter spec initialisation

 drivers/net/sfc/efx.h        |    5 +-
 drivers/net/sfc/ethtool.c    |   99 ++++++++---------
 drivers/net/sfc/filter.c     |  252 ++++++++++++++++++++++++++++++++++--------
 drivers/net/sfc/filter.h     |  149 ++++++-------------------
 drivers/net/sfc/io.h         |  153 +++++++++++++++-----------
 drivers/net/sfc/net_driver.h |   57 +++++++---
 drivers/net/sfc/nic.c        |   42 +++++++-
 drivers/net/sfc/tx.c         |   17 +++-
 8 files changed, 468 insertions(+), 306 deletions(-)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


