From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [RFC][PATCH 0/4] RFS hardware acceleration
Date: Mon, 20 Sep 2010 20:01:30 +0100
Message-ID: <1285009290.2282.121.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:8938 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753830Ab0ITTBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 15:01:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom,

This patch series extends RFS to use hardware RX filters where
available.  Depending on the number of hardware RX queues and their
IRQs' affinity, this should reduce the need for IPIs or at least get
packets delivered to the right NUMA node.

I've implemented the driver side of this for our hardware, though I
don't know whether you have any of that to test on.  I would be very
interested to know how much this can help in the sort of cases where you
use RFS.

Ben.

Ben Hutchings (4):
  IRQ: IRQ groups for multiqueue devices
  net: RPS: Enable hardware acceleration
  sfc: Implement RFS acceleration
  sfc/RFS/irq_group debug output

 drivers/net/sfc/efx.c     |   49 +++++++++++---
 drivers/net/sfc/efx.h     |    9 +++
 drivers/net/sfc/filter.c  |  109 +++++++++++++++++++++++++++++
 include/linux/irq.h       |   52 ++++++++++++++
 include/linux/netdevice.h |   29 +++++++-
 kernel/irq/manage.c       |  170 +++++++++++++++++++++++++++++++++++++++++++++
 net/core/dev.c            |   88 ++++++++++++++++++++++--
 7 files changed, 488 insertions(+), 18 deletions(-)

-- 
1.7.2.1


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

