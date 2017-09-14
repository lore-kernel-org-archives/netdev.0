From: Haneen Mohammed <hamohammed.sa@gmail.com>
Subject: [PATCH] staging: irda: Remove typedef struct
Date: Wed, 13 Sep 2017 22:55:38 -0600
Message-ID: <20170914045538.GA24121@Haneen>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Samuel Ortiz <samuel@sortiz.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        linux-kernel@vger.kernel.org
To: outreachy-kernel <outreachy-kernel@googlegroups.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch remove typedef from a structure with all its ocurrences
since using typedefs for structures is discouraged.
Issue found using Coccinelle:

@r1@
type T;
@@

typedef struct { ... } T;

@script:python c1@
T2;
T << r1.T;
@@
if T[-2:] =="_t" or T[-2:] == "_T":
	coccinelle.T2 = T[:-2];
else:
	coccinelle.T2 = T;

print T, coccinelle.T2

@r2@
type r1.T;
identifier c1.T2;
@@
-typedef
struct
+ T2
{ ... }
-T
;

@r3@
type r1.T;
identifier c1.T2;
@@
-T
+struct T2

Signed-off-by: Haneen Mohammed <hamohammed.sa@gmail.com>
---
 drivers/staging/irda/include/net/irda/qos.h | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/irda/include/net/irda/qos.h b/drivers/staging/irda/include/net/irda/qos.h
index 05a5a24..a0315b5 100644
--- a/drivers/staging/irda/include/net/irda/qos.h
+++ b/drivers/staging/irda/include/net/irda/qos.h
@@ -58,23 +58,23 @@
 #define IR_16000000 0x02
 
 /* Quality of Service information */
-typedef struct {
+struct qos_value {
 	__u32 value;
 	__u16 bits; /* LSB is first byte, MSB is second byte */
-} qos_value_t;
+};
 
 struct qos_info {
 	magic_t magic;
 
-	qos_value_t baud_rate;       /* IR_11520O | ... */
-	qos_value_t max_turn_time;
-	qos_value_t data_size;
-	qos_value_t window_size;
-	qos_value_t additional_bofs;
-	qos_value_t min_turn_time;
-	qos_value_t link_disc_time;
+	struct qos_value baud_rate;       /* IR_11520O | ... */
+	struct qos_value max_turn_time;
+	struct qos_value data_size;
+	struct qos_value window_size;
+	struct qos_value additional_bofs;
+	struct qos_value min_turn_time;
+	struct qos_value link_disc_time;
 	
-	qos_value_t power;
+	struct qos_value power;
 };
 
 extern int sysctl_max_baud_rate;
-- 
2.7.4
