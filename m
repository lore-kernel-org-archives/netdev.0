From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [RFC PATCH net-next-2.6 0/2] Automatic XPS mapping
Date: Fri, 18 Feb 2011 16:13:27 +0000
Message-ID: <1298045607.2570.17.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	sf-linux-drivers <linux-net-drivers@solarflare.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:39892 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751758Ab1BRQNa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Feb 2011 11:13:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the same way that we maintain a mapping CPUs to RX queues for RFS
acceleration based on current IRQ affinity and the CPU topology, we can
maintain a mapping of CPUs to TX queues for queue selection in XPS.  (In
fact this may be the same mapping.)

Questions:
- Does this make a real difference to performance?
  (I've only barely tested this.)
- Should there be a way to disable it?
- Should the automatic mapping be made visible?
  (This applies RFS acceleration too.)
- Should different mappings be allowed for different traffic classes,
  in case they have separate sets of TX interrupts with different
  affinity?
  (This applies to manual XPS configuration too.)

Ben Hutchings (2):
  net: XPS: Allow driver to provide a default mapping of CPUs to TX
    queues
  sfc: Add CPU queue mapping for XPS

 drivers/net/sfc/efx.c     |   59 +++++++++++++++++++++++++++++++-------------
 include/linux/netdevice.h |   10 +++++--
 net/Kconfig               |   17 +++++++++----
 net/core/dev.c            |   41 +++++++++++++++++-------------
 4 files changed, 83 insertions(+), 44 deletions(-)

-- 
1.7.3.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

