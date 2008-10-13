From: Roland Dreier <rdreier@cisco.com>
Subject: [PATCH 1/2] enic: Fix build without _HAVE_ARCH_IPV6_CSUM
Date: Mon, 13 Oct 2008 13:35:22 -0700
Message-ID: <adafxn0p71x.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: scofeldm@cisco.com, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:15008 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753050AbYJMUfX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 16:35:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>

On architectures (such as powerpc) that don't define
_HAVE_ARCH_IPV6_CSUM, the enic compile fails with

    drivers/net/enic/enic_main.c: In function 'enic_queue_wq_skb_tso':
    drivers/net/enic/enic_main.c:575: error: implicit declaration of function 'csum_ipv6_magic'

Fix this by including <net/ip6_checksum.h>

Signed-off-by: Roland Dreier <rolandd@cisco.com>
---
Jeff, this is part of a patch Scott sent a while ago
(https://kerneltrap.org/mailarchive/linux-netdev/2008/9/20/3350614/thread)
that seems to have gotten dropped.  Please apply.

 drivers/net/enic/enic_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index f3a47a8..80119c9 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -35,6 +35,8 @@
 #include <linux/ipv6.h>
 #include <linux/tcp.h>
 
+#include <net/ip6_checksum.h>
+
 #include "cq_enet_desc.h"
 #include "vnic_dev.h"
 #include "vnic_intr.h"
