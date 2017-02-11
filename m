From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 4/7] staging: r8712u: Fix Sparse warning in rtl871x_xmit.c
Date: Fri, 10 Feb 2017 21:30:27 -0600
Message-ID: <20170211033030.28827-5-Larry.Finger@lwfinger.net>
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
  CHECK   drivers/staging/rtl8712/rtl871x_xmit.c
drivers/staging/rtl8712/rtl871x_xmit.c:350:44: warning: restricted __le32 degrades to integer
drivers/staging/rtl8712/rtl871x_xmit.c:491:23: warning: incorrect type in initializer (different base types)
drivers/staging/rtl8712/rtl871x_xmit.c:491:23:    expected unsigned short [usertype] *fctrl
drivers/staging/rtl8712/rtl871x_xmit.c:491:23:    got restricted __le16 *<noident>
drivers/staging/rtl8712/rtl871x_xmit.c:580:36: warning: incorrect type in assignment (different base types)
drivers/staging/rtl8712/rtl871x_xmit.c:580:36:    expected unsigned short [unsigned] [short] [usertype] <noident>
drivers/staging/rtl8712/rtl871x_xmit.c:580:36:    got restricted __be16 [usertype] <noident>

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8712/rtl871x_xmit.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/rtl8712/rtl871x_xmit.c b/drivers/staging/rtl8712/rtl871x_xmit.c
index 4ab82ba..de88819 100644
--- a/drivers/staging/rtl8712/rtl871x_xmit.c
+++ b/drivers/staging/rtl8712/rtl871x_xmit.c
@@ -347,7 +347,8 @@ sint r8712_update_attrib(struct _adapter *padapter, _pkt *pkt,
 	 * some settings above.
 	 */
 	if (check_fwstate(pmlmepriv, WIFI_MP_STATE))
-		pattrib->priority = (txdesc.txdw1 >> QSEL_SHT) & 0x1f;
+		pattrib->priority =
+		    (le32_to_cpu(txdesc.txdw1) >> QSEL_SHT) & 0x1f;
 	return _SUCCESS;
 }
 
@@ -488,7 +489,7 @@ static sint make_wlanhdr(struct _adapter *padapter, u8 *hdr,
 	struct ieee80211_hdr *pwlanhdr = (struct ieee80211_hdr *)hdr;
 	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
 	struct qos_priv *pqospriv = &pmlmepriv->qospriv;
-	u16 *fctrl = &pwlanhdr->frame_ctl;
+	__le16 *fctrl = &pwlanhdr->frame_ctl;
 
 	memset(hdr, 0, WLANHDR_OFFSET);
 	SetFrameSubType(fctrl, pattrib->subtype);
@@ -577,7 +578,7 @@ static sint r8712_put_snap(u8 *data, u16 h_proto)
 	snap->oui[0] = oui[0];
 	snap->oui[1] = oui[1];
 	snap->oui[2] = oui[2];
-	*(u16 *)(data + SNAP_SIZE) = htons(h_proto);
+	*(__be16 *)(data + SNAP_SIZE) = htons(h_proto);
 	return SNAP_SIZE + sizeof(u16);
 }
 
-- 
2.10.2
