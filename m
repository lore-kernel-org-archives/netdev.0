From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 1/3] staging: r8192ee: Fix kernel WARN splat associated with
 rate control
Date: Mon, 26 May 2014 14:06:04 -0500
Message-ID: <1401131166-6313-2-git-send-email-Larry.Finger@lwfinger.net>
References: <1401131166-6313-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1401131166-6313-1-git-send-email-Larry.Finger@lwfinger.net>
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

The 0day kernel testing robot got the kernel warning caused by trying
to register a particular rate-control algorithm more than once. I believe
that the core already protects against a particular driver doing the
registration more than once, but an analysis of the code reveals that
the identical name is used for the rtlwifi drivers in the regular
wireless tree, and the staging drivers r8192ee and r8821ae. The fix
is to rename the algorithm used in r8192ee.

Reported-by: Jet Chen <jet.chen@intel.com>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Tested-by: Jet Chen <jet.chen@intel.com>
---
 drivers/staging/rtl8192ee/rc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/rtl8192ee/rc.c b/drivers/staging/rtl8192ee/rc.c
index f0ce6a9..c4c34dd 100644
--- a/drivers/staging/rtl8192ee/rc.c
+++ b/drivers/staging/rtl8192ee/rc.c
@@ -267,7 +267,7 @@ static void rtl_rate_free_sta(void *rtlpriv,
 }
 
 static struct rate_control_ops rtl_rate_ops = {
-	.name = "rtl_rc",
+	.name = "rtl_rc_92e",
 	.alloc = rtl_rate_alloc,
 	.free = rtl_rate_free,
 	.alloc_sta = rtl_rate_alloc_sta,
-- 
1.8.4.5
