From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 1/3] staging: r8188eu: Calling rtw_get_stainfo() with a NULL
 sta_addr will return NULL
Date: Wed,  9 Apr 2014 11:12:58 -0500
Message-ID: <1397059980-11942-2-git-send-email-Larry.Finger@lwfinger.net>
References: <1397059980-11942-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Stable <stable@vger.kernel.org>, Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1397059980-11942-1-git-send-email-Larry.Finger@lwfinger.net>
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

This makes the follow-on check for psta != NULL pointless and makes
the whole exercise rather pointless. This is another case of why
blindly zero-initializing variables when they are declared is bad.

Reported-by: Jes Sorensen <Jes.Sorensen@redhat.com>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org>
---
 drivers/staging/rtl8188eu/core/rtw_recv.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_recv.c b/drivers/staging/rtl8188eu/core/rtw_recv.c
index 636ec55..01fcabc 100644
--- a/drivers/staging/rtl8188eu/core/rtw_recv.c
+++ b/drivers/staging/rtl8188eu/core/rtw_recv.c
@@ -545,7 +545,7 @@ static struct recv_frame *decryptor(struct adapter *padapter,
 static struct recv_frame *portctrl(struct adapter *adapter,
 				   struct recv_frame *precv_frame)
 {
-	u8   *psta_addr = NULL, *ptr;
+	u8   *psta_addr, *ptr;
 	uint  auth_alg;
 	struct recv_frame *pfhdr;
 	struct sta_info *psta;
@@ -558,7 +558,6 @@ static struct recv_frame *portctrl(struct adapter *adapter,
 
 
 	pstapriv = &adapter->stapriv;
-	psta = rtw_get_stainfo(pstapriv, psta_addr);
 
 	auth_alg = adapter->securitypriv.dot11AuthAlgrthm;
 
@@ -566,6 +565,7 @@ static struct recv_frame *portctrl(struct adapter *adapter,
 	pfhdr = precv_frame;
 	pattrib = &pfhdr->attrib;
 	psta_addr = pattrib->ta;
+	psta = rtw_get_stainfo(pstapriv, psta_addr);
 
 	prtnframe = NULL;
 
-- 
1.8.1.4
