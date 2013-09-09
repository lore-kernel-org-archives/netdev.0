From: Chris Healy <cphealy@gmail.com>
Subject: [PATCH 1/1] bridge: fix message_age_timer calculation
Date: Mon,  9 Sep 2013 09:56:08 -0700
Message-ID: <1378745768-4495-1-git-send-email-cphealy@gmail.com>
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	buytenh@wantstofly.org
To: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

This changes the message_age_timer calculation to use the BPDU's max age as opposed to the local bridge's max age.  This is in accordance with section 8.6.2.3.2 Step 2 of the 802.1D-1998 sprecification.

With the current implementation, when running with very large bridge diameters, convergance will not always occur even if a root bridge is configured to have a longer max age.

Tested successfully on bridge diameters of ~200.

Signed-off-by: Chris Healy <cphealy@gmail.com>
---
 net/bridge/br_stp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index 1c0a50f..f1887ba 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -209,7 +209,7 @@ static void br_record_config_information(struct net_bridge_port *p,
 	p->designated_age = jiffies - bpdu->message_age;
 
 	mod_timer(&p->message_age_timer, jiffies
-		  + (p->br->max_age - bpdu->message_age));
+		  + (bpdu->max_age - bpdu->message_age));
 }
 
 /* called under bridge lock */
-- 
1.8.1.2
