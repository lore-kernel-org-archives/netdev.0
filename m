From: Srishti Sharma <srishtishar@gmail.com>
Subject: [PATCH 2/2] Staging: irda: Remove parentheses on the right of
 assignment
Date: Sat, 16 Sep 2017 02:36:16 +0530
Message-ID: <9380189edb2722544981c868699ade29ab5c297d.1505508423.git.srishtishar@gmail.com>
References: <cover.1505508423.git.srishtishar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, gregkh@linuxfoundation.org,
 linux-kernel@vger.kernel.org, outreachy-kernel@googlegroups.com,
 Srishti Sharma <srishtishar@gmail.com>, netdev@vger.kernel.org
To: samuel@sortiz.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <cover.1505508423.git.srishtishar@gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Parentheses are not needed on the right hand side of assignment
statement in most cases. Done using the following semantic
patch by coccinelle.

@@
identifier E,F,G,f;
expression e,r;
@@

(
E = (G == F);
|
E = (e == r);
|
E =
-(
...
-)
;
)

Signed-off-by: Srishti Sharma <srishtishar@gmail.com>
---
 drivers/staging/irda/drivers/mcs7780.c | 4 ++--
 drivers/staging/irda/net/irqueue.c     | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/irda/drivers/mcs7780.c b/drivers/staging/irda/drivers/mcs7780.c
index 2b674d5..d52e9f4 100644
--- a/drivers/staging/irda/drivers/mcs7780.c
+++ b/drivers/staging/irda/drivers/mcs7780.c
@@ -605,7 +605,7 @@ static int mcs_speed_change(struct mcs_cb *mcs)
 	if (mcs->new_speed <= 115200) {
 		rval &= ~MCS_FIR;
 
-		rst = (mcs->speed > 115200);
+		rst = mcs->speed > 115200;
 		if (rst)
 			mcs_set_reg(mcs, MCS_MINRXPW_REG, 0);
 
@@ -619,7 +619,7 @@ static int mcs_speed_change(struct mcs_cb *mcs)
 	} else {
 		rval |= MCS_FIR;
 
-		rst = (mcs->speed != 4000000);
+		rst = mcs->speed != 4000000;
 		if (rst)
 			mcs_set_reg(mcs, MCS_MINRXPW_REG, 5);
 
diff --git a/drivers/staging/irda/net/irqueue.c b/drivers/staging/irda/net/irqueue.c
index 5aab072..14291cb 100644
--- a/drivers/staging/irda/net/irqueue.c
+++ b/drivers/staging/irda/net/irqueue.c
@@ -217,7 +217,7 @@ static __u32 hash( const char* name)
 
 	while(*name) {
 		h = (h<<4) + *name++;
-		g = (h & 0xf0000000);
+		g = h & 0xf0000000;
 		if (g)
 			h ^=g>>24;
 		h &=~g;
-- 
2.7.4
