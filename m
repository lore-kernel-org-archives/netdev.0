From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-2.6] forcedeth: call vlan_mode only if hw supports vlans
Date: Thu, 18 Aug 2011 08:37:51 +0200
Message-ID: <1313649471-31555-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, mirqus@gmail.com, mingo@elte.hu,
	torvalds@linux-foundation.org, akpm@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48822 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755131Ab1HRGid (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Aug 2011 02:38:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If hw does not support vlans, dont call nv_vlan_mode because it has no point.
I believe that this should fix issues on older non-vlan supportive
chips (like Ingo has).

Reported-ty: Ingo Molnar <mingo@elte.hu>
Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/forcedeth.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index e55df30..6d5fbd4 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -5615,7 +5615,8 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		goto out_error;
 	}
 
-	nv_vlan_mode(dev, dev->features);
+	if (id->driver_data & DEV_HAS_VLAN)
+		nv_vlan_mode(dev, dev->features);
 
 	netif_carrier_off(dev);
 
-- 
1.7.6

