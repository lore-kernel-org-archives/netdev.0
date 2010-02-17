From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 12/18] igb: inline igb_maybe_stop_tx
Date: Wed, 17 Feb 2010 03:04:18 -0800
Message-ID: <20100217110416.17723.4456.stgit@localhost.localdomain>
References: <20100217105953.17723.36633.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Nicholas Nunley <nicholasx.d.nunley@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:44349 "EHLO
	qmta02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755223Ab0BQLEf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 06:04:35 -0500
In-Reply-To: <20100217105953.17723.36633.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Nunley <nicholasx.d.nunley@intel.com>

igb_maybe_stop_tx() is extremely small and appears in several spots in
the tx hotpath. This change inlines the function for a possible
performance boost.

Signed-off-by: Nicholas Nunley <nicholasx.d.nunley@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index cba0115..a1fe581 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3758,7 +3758,7 @@ static int __igb_maybe_stop_tx(struct igb_ring *tx_ring, int size)
 	return 0;
 }
 
-static int igb_maybe_stop_tx(struct igb_ring *tx_ring, int size)
+static inline int igb_maybe_stop_tx(struct igb_ring *tx_ring, int size)
 {
 	if (igb_desc_unused(tx_ring) >= size)
 		return 0;

