From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 10/10] fakehard: use START-CONFIRM
	primitive to report START failure
Date: Fri,  7 Aug 2009 16:58:45 +0400
Message-ID: <1249649925-11996-11-git-send-email-dbaryshkov@gmail.com>
References: <1249649925-11996-1-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-2-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-3-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-4-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-5-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-6-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-7-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-8-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-9-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-10-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1249649925-11996-10-git-send-email-dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/ieee802154/fakehard.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/ieee802154/fakehard.c b/drivers/ieee802154/fakehard.c
index 8a52e6e..2bc6c0c 100644
--- a/drivers/ieee802154/fakehard.c
+++ b/drivers/ieee802154/fakehard.c
@@ -177,18 +177,14 @@ static int fake_disassoc_req(struct net_device *dev,
  *
  * Note: This is in section 7.5.2.3 of the IEEE 802.15.4-2006
  * document, with 7.3.8 describing coordinator realignment.
- *
- * Note: There is currently no way to notify the coordinator userland
- * program of whether or not the PAN has started successfully. As
- * such, the coordinator program cannot know when the MAC has
- * completed starting the network and will simply have to assume
- * completeness based on some form of time delay.
  */
 static int fake_start_req(struct net_device *dev, struct ieee802154_addr *addr,
 				u8 channel,
 				u8 bcn_ord, u8 sf_ord, u8 pan_coord, u8 blx,
 				u8 coord_realign)
 {
+	/* We don't emulate beacons here at all, so START should fail */
+	ieee802154_nl_start_confirm(dev, IEEE802154_INVALID_PARAMETER);
 	return 0;
 }
 
-- 
1.6.3.3


------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with 
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
