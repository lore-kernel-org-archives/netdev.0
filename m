From: Matt Wilson <msw@amazon.com>
Subject: [PATCH v2] xen-netback: allow changing the MAC address of the interface
Date: Tue, 22 Jan 2013 18:08:25 +0000
Message-ID: <1358878105-7890-1-git-send-email-msw@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Matt Wilson <msw@amazon.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-4101.amazon.com ([72.21.198.25]:39048 "EHLO
	smtp-fw-4101.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753963Ab3AVSIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 13:08:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sometimes it is useful to be able to change the MAC address of the
interface for netback devices. For example, when using ebtables it may
be useful to be able to distinguish traffic from different interfaces
without depending on the interface name.

Reported-by: Nikita Borzykh <sample.n@gmail.com>
Reported-by: Paul Harvey <stockingpaul@hotmail.com>
Cc: netdev@vger.kernel.org
Cc: xen-devel@lists.xen.org
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Acked-by: Ian Campbell <ian.campbell@citrix.com>
Signed-off-by: Matt Wilson <msw@amazon.com>

---
Changes since v1:
 * No code changes, only updated commit message
---
 drivers/net/xen-netback/interface.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index b7d41f8..f733cae 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -238,6 +238,8 @@ static const struct net_device_ops xenvif_netdev_ops = {
 	.ndo_stop	= xenvif_close,
 	.ndo_change_mtu	= xenvif_change_mtu,
 	.ndo_fix_features = xenvif_fix_features,
+	.ndo_set_mac_address = eth_mac_addr,
+	.ndo_validate_addr   = eth_validate_addr,
 };
 
 struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
-- 
1.7.4.5
