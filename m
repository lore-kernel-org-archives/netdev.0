From: Mark Einon <mark.einon@gmail.com>
Subject: [PATCH 2/8] staging: et131x: Don't handle rx/tx packets when changing
 mtu
Date: Wed, 20 Aug 2014 23:17:52 +0100
Message-ID: <1408573078-9320-3-git-send-email-mark.einon@gmail.com>
References: <1408573078-9320-1-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Mark Einon <mark.einon@gmail.com>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1408573078-9320-1-git-send-email-mark.einon@gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

There's no need to handle any rx/tx interrupts in the middle of an mtu
change, so don't.

After this change, receive and transmit interrupts are only handled in
one place, which paves the way to using NAPI.

Signed-off-by: Mark Einon <mark.einon@gmail.com>
---
 drivers/staging/et131x/et131x.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/staging/et131x/et131x.c b/drivers/staging/et131x/et131x.c
index ac6700b..fffe763 100644
--- a/drivers/staging/et131x/et131x.c
+++ b/drivers/staging/et131x/et131x.c
@@ -4434,8 +4434,6 @@ static int et131x_change_mtu(struct net_device *netdev, int new_mtu)
 		return -EINVAL;
 
 	et131x_disable_txrx(netdev);
-	et131x_handle_send_interrupt(adapter);
-	et131x_handle_recv_interrupt(adapter);
 
 	/* Set the new MTU */
 	netdev->mtu = new_mtu;
-- 
2.1.0
