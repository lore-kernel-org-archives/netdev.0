From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH V2] irda: use msecs_to_jiffies for conversion to jiffies
Date: Mon, 25 May 2015 08:16:50 +0200
Message-ID: <1432534610-4643-1-git-send-email-hofrat@osadl.org>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Nicholas Mc Guire <hofrat@osadl.org>
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

API compliance scanning with coccinelle flagged:
./net/irda/timer.c:63:35-37: use of msecs_to_jiffies probably perferable

Converting milliseconds to jiffies by "val * HZ / 1000" technically
is not a clean solution as it does not handle all corner cases correctly.
By changing the conversion to use msecs_to_jiffies(val) conversion is
correct in all cases. Further the () around the arithmetic expression
was dropped.

Patch was compile tested for x86_64_defconfig + CONFIG_IRDA=m

Patch is against 4.1-rc4 (localversion-next is -next-20150522)

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

V2: botched prefix in the subject line updated to irda: thanks
    to David Miller <davem@davemloft.net>

Should the Status note at the top of the file be updated ? it seems
the file has been marked experimental since at least 1999 ?

 net/irda/timer.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/irda/timer.c b/net/irda/timer.c
index 0c4c115..f2280f7 100644
--- a/net/irda/timer.c
+++ b/net/irda/timer.c
@@ -60,8 +60,8 @@ void irlap_start_query_timer(struct irlap_cb *self, int S, int s)
 	 * to avoid messing with for incoming connections requests and
 	 * to accommodate devices that perform discovery slower than us.
 	 * Jean II */
-	timeout = ((sysctl_slot_timeout * HZ / 1000) * (S - s)
-		   + XIDEXTRA_TIMEOUT + SMALLBUSY_TIMEOUT);
+	timeout = msecs_to_jiffies(sysctl_slot_timeout) * (S - s)
+		   + XIDEXTRA_TIMEOUT + SMALLBUSY_TIMEOUT;
 
 	/* Set or re-set the timer. We reset the timer for each received
 	 * discovery query, which allow us to automatically adjust to
-- 
1.7.10.4
