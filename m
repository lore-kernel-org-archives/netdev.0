From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 9/9] e1000e: Use sizeof struct rather than
	pointer in e1000_get_eeprom()
Date: Tue, 01 Dec 2009 17:54:24 -0800
Message-ID: <20091202015406.592.42534.stgit@localhost.localdomain>
References: <20091202015250.592.56893.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Roel Kluin <roel.kluin@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.emeryville.ca.mail.comcast.net ([76.96.27.212]:58949
	"EHLO QMTA14.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752742AbZLBByd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 20:54:33 -0500
In-Reply-To: <20091202015250.592.56893.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>

Don't use the sizeof the pointer to clear the result

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ethtool.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index b6243ca..0aa50c2 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -535,7 +535,8 @@ static int e1000_get_eeprom(struct net_device *netdev,
 
 	if (ret_val) {
 		/* a read error occurred, throw away the result */
-		memset(eeprom_buff, 0xff, sizeof(eeprom_buff));
+		memset(eeprom_buff, 0xff, sizeof(u16) *
+		       (last_word - first_word + 1));
 	} else {
 		/* Device's eeprom is always little-endian, word addressable */
 		for (i = 0; i < last_word - first_word + 1; i++)

