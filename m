From: Joe Perches <joe@perches.com>
Subject: [PATCH] i40e: Fix i40e_print_features() VEB mode output
Date: Wed, 02 Dec 2015 00:38:55 -0800
Message-ID: <1449045535.3716.10.camel@perches.com>
References: <1448475679-57194-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1448475679-57194-5-git-send-email-jeffrey.t.kirsher@intel.com>
	 <5655FD72.70902@cogentembedded.com> <1448476535.3021.5.camel@intel.com>
	 <1448480194.20113.48.camel@perches.com>
	 <1449002936.1593.10.camel@perches.com> <1449041100.3224.17.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Shannon Nelson <shannon.nelson@intel.com>
To: intel-wired-lan <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0247.hostedemail.com ([216.40.44.247]:39033 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753949AbbLBIjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 03:39:00 -0500
In-Reply-To: <1449041100.3224.17.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 7fd89545f337 ("i40e: remove BUG_ON from feature string building"=
)
added defective output when I40E_FLAG_VEB_MODE_ENABLED was set in
function i40e_print_features.

=46ix it.

Miscellanea:

o Remove unnecessary string variable
o Add space before not after fixed strings
o Use kmalloc not kzalloc
o Don't initialize i to 0, use result of first snprintf

Noticed-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Signed-off-by: Joe Perches <joe@perches.com>
---
=A0drivers/net/ethernet/intel/i40e/i40e_main.c | 42 +++++++++++++------=
----------
=A01 file changed, 19 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/=
ethernet/intel/i40e/i40e_main.c
index 4b7d874..145eeb5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -10240,52 +10240,48 @@ static int i40e_setup_pf_filter_control(struc=
t i40e_pf *pf)
=A0static void i40e_print_features(struct i40e_pf *pf)
=A0{
=A0	struct i40e_hw *hw =3D &pf->hw;
-	char *buf, *string;
-	int i =3D 0;
+	char *buf;
+	int i;
=A0
-	string =3D kzalloc(INFO_STRING_LEN, GFP_KERNEL);
-	if (!string) {
-		dev_err(&pf->pdev->dev, "Features string allocation failed\n");
+	buf =3D kmalloc(INFO_STRING_LEN, GFP_KERNEL);
+	if (!buf)
=A0		return;
-	}
-
-	buf =3D string;
=A0
-	i +=3D snprintf(&buf[i], REMAIN(i), "Features: PF-id[%d] ", hw->pf_id=
);
+	i =3D snprintf(buf, INFO_STRING_LEN, "Features: PF-id[%d]", hw->pf_id=
);
=A0#ifdef CONFIG_PCI_IOV
-	i +=3D snprintf(&buf[i], REMAIN(i), "VFs: %d ", pf->num_req_vfs);
+	i +=3D snprintf(&buf[i], REMAIN(i), " VFs: %d", pf->num_req_vfs);
=A0#endif
-	i +=3D snprintf(&buf[i], REMAIN(i), "VSIs: %d QP: %d RX: %s ",
+	i +=3D snprintf(&buf[i], REMAIN(i), " VSIs: %d QP: %d RX: %s",
=A0		=A0=A0=A0=A0=A0=A0pf->hw.func_caps.num_vsis,
=A0		=A0=A0=A0=A0=A0=A0pf->vsi[pf->lan_vsi]->num_queue_pairs,
=A0		=A0=A0=A0=A0=A0=A0pf->flags & I40E_FLAG_RX_PS_ENABLED ? "PS" : "1B=
UF");
=A0
=A0	if (pf->flags & I40E_FLAG_RSS_ENABLED)
-		i +=3D snprintf(&buf[i], REMAIN(i), "RSS ");
+		i +=3D snprintf(&buf[i], REMAIN(i), " RSS");
=A0	if (pf->flags & I40E_FLAG_FD_ATR_ENABLED)
-		i +=3D snprintf(&buf[i], REMAIN(i), "FD_ATR ");
+		i +=3D snprintf(&buf[i], REMAIN(i), " FD_ATR");
=A0	if (pf->flags & I40E_FLAG_FD_SB_ENABLED) {
-		i +=3D snprintf(&buf[i], REMAIN(i), "FD_SB ");
-		i +=3D snprintf(&buf[i], REMAIN(i), "NTUPLE ");
+		i +=3D snprintf(&buf[i], REMAIN(i), " FD_SB");
+		i +=3D snprintf(&buf[i], REMAIN(i), " NTUPLE");
=A0	}
=A0	if (pf->flags & I40E_FLAG_DCB_CAPABLE)
-		i +=3D snprintf(&buf[i], REMAIN(i), "DCB ");
+		i +=3D snprintf(&buf[i], REMAIN(i), " DCB");
=A0#if IS_ENABLED(CONFIG_VXLAN)
-	i +=3D snprintf(&buf[i], REMAIN(i), "VxLAN ");
+	i +=3D snprintf(&buf[i], REMAIN(i), " VxLAN");
=A0#endif
=A0	if (pf->flags & I40E_FLAG_PTP)
-		i +=3D snprintf(&buf[i], REMAIN(i), "PTP ");
+		i +=3D snprintf(&buf[i], REMAIN(i), " PTP");
=A0#ifdef I40E_FCOE
=A0	if (pf->flags & I40E_FLAG_FCOE_ENABLED)
-		i +=3D snprintf(&buf[i], REMAIN(i), "FCOE ");
+		i +=3D snprintf(&buf[i], REMAIN(i), " FCOE");
=A0#endif
=A0	if (pf->flags & I40E_FLAG_VEB_MODE_ENABLED)
-		i +=3D snprintf(&buf[i], REMAIN(i), "VEPA ");
+		i +=3D snprintf(&buf[i], REMAIN(i), " VEB");
=A0	else
-		buf +=3D sprintf(buf, "VEPA ");
+		i +=3D snprintf(&buf[i], REMAIN(i), " VEPA");
=A0
-	dev_info(&pf->pdev->dev, "%s\n", string);
-	kfree(string);
+	dev_info(&pf->pdev->dev, "%s\n", buf);
+	kfree(buf);
=A0	WARN_ON(i > INFO_STRING_LEN);
=A0}
=A0
