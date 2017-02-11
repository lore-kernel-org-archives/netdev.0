From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 5/7] staging: r8712u: Fix Sparse endian warning in
 rtl871x_recv.c
Date: Fri, 10 Feb 2017 21:30:28 -0600
Message-ID: <20170211033030.28827-6-Larry.Finger@lwfinger.net>
References: <20170211033030.28827-1-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170211033030.28827-1-Larry.Finger@lwfinger.net>
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

Sparse reports the following:
  CHECK   drivers/staging/rtl8712/rtl871x_recv.c
drivers/staging/rtl8712/rtl871x_recv.c:657:21: warning: incorrect type in assignment (different base types)
drivers/staging/rtl8712/rtl871x_recv.c:657:21:    expected unsigned short [unsigned] [assigned] [usertype] len
drivers/staging/rtl8712/rtl871x_recv.c:657:21:    got restricted __be16 [usertype] <noident>

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8712/rtl871x_recv.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/rtl8712/rtl871x_recv.c b/drivers/staging/rtl8712/rtl871x_recv.c
index 147b75b..2ef31a4 100644
--- a/drivers/staging/rtl8712/rtl871x_recv.c
+++ b/drivers/staging/rtl8712/rtl871x_recv.c
@@ -654,8 +654,9 @@ sint r8712_wlanhdr_to_ethhdr(union recv_frame *precvframe)
 	memcpy(ptr, pattrib->dst, ETH_ALEN);
 	memcpy(ptr + ETH_ALEN, pattrib->src, ETH_ALEN);
 	if (!bsnaphdr) {
-		len = htons(len);
-		memcpy(ptr + 12, &len, 2);
+		__be16 be_tmp = htons(len);
+
+		memcpy(ptr + 12, &be_tmp, 2);
 	}
 	return _SUCCESS;
 }
-- 
2.10.2
