From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: broadcom: bnx2x: make a couple of const arrays static
Date: Tue, 11 Jul 2017 11:52:23 +0100
Message-ID: <20170711105223.14024-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <ariel.elior@cavium.com>,
        everest-linux-l2@cavium.com, netdev@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Don't populate various tables on the stack but make them static const.
Makes the object code smaller by nearly 200 bytes:

Before:
   text	   data	    bss	    dec	    hex	filename
 113468	  11200	      0	 124668	  1e6fc	bnx2x_ethtool.o

After:
   text	   data	    bss	    dec	    hex	filename
 113129	  11344	      0	 124473	  1e639	bnx2x_ethtool.o

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 43423744fdfa..21bc4bed6b26 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -2886,7 +2886,7 @@ static int bnx2x_test_nvram_tbl(struct bnx2x *bp,
 
 static int bnx2x_test_nvram(struct bnx2x *bp)
 {
-	const struct crc_pair nvram_tbl[] = {
+	static const struct crc_pair nvram_tbl[] = {
 		{     0,  0x14 }, /* bootstrap */
 		{  0x14,  0xec }, /* dir */
 		{ 0x100, 0x350 }, /* manuf_info */
@@ -2895,7 +2895,7 @@ static int bnx2x_test_nvram(struct bnx2x *bp)
 		{ 0x708,  0x70 }, /* manuf_key_info */
 		{     0,     0 }
 	};
-	const struct crc_pair nvram_tbl2[] = {
+	static const struct crc_pair nvram_tbl2[] = {
 		{ 0x7e8, 0x350 }, /* manuf_info2 */
 		{ 0xb38,  0xf0 }, /* feature_info */
 		{     0,     0 }
-- 
2.11.0

