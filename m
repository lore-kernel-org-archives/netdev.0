From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 6/15] drivers/net/wireless/iwlegacy/4965-mac.c: adjust duplicate test
Date: Mon, 21 Jan 2013 14:02:50 +0100
Message-ID: <1358773378-4700-7-git-send-email-Julia.Lawall@lip6.fr>
References: <1358773378-4700-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358773378-4700-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Delete successive tests to the same location.  This looks like simple code
duplication.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@s exists@
local idexpression y;
expression x,e;
@@

*if ( \(x == NULL\|IS_ERR(x)\|y != 0\) )
 { ... when forall
   return ...; }
... when != \(y = e\|y += e\|y -= e\|y |= e\|y &= e\|y++\|y--\|&y\)
    when != \(XT_GETPAGE(...,y)\|WMI_CMD_BUF(...)\)
*if ( \(x == NULL\|IS_ERR(x)\|y != 0\) )
 { ... when forall
   return ...; }
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/wireless/iwlegacy/4965-mac.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/wireless/iwlegacy/4965-mac.c b/drivers/net/wireless/iwlegacy/4965-mac.c
index 10fc249..0195190 100644
--- a/drivers/net/wireless/iwlegacy/4965-mac.c
+++ b/drivers/net/wireless/iwlegacy/4965-mac.c
@@ -6572,9 +6572,6 @@ il4965_pci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (err)
 		goto out_free_eeprom;
 
-	if (err)
-		goto out_free_eeprom;
-
 	/* extract MAC Address */
 	il4965_eeprom_get_mac(il, il->addresses[0].addr);
 	D_INFO("MAC address: %pM\n", il->addresses[0].addr);
