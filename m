From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 03/21] orinoco: remove underscores from little-endian field names
Date: Fri, 07 Apr 2006 04:10:24 -0400
Message-ID: <20060407081023.16107.43555.stgit@dv.roinet.com>
References: <20060407081019.16107.67672.stgit@dv.roinet.com>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
In-Reply-To: <20060407081019.16107.67672.stgit-fdEtzkpK75rby3iVrkZq2A@public.gmane.org>
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>

Sparse is much better at finding endianess issues than such visual cues.

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
---

 drivers/net/wireless/spectrum_cs.c |   28 ++++++++++++++--------------
 1 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/wireless/spectrum_cs.c b/drivers/net/wireless/sp=
ectrum_cs.c
index 0b0bce7..58c153a 100644
--- a/drivers/net/wireless/spectrum_cs.c
+++ b/drivers/net/wireless/spectrum_cs.c
@@ -120,8 +120,8 @@ #define TEXT_END	0x1A		/* End of text he
  * Each block has the following structure.
  */
 struct dblock {
-	__le32 _addr;		/* adapter address where to write the block */
-	__le16 _len;		/* length of the data only, in bytes */
+	__le32 addr;		/* adapter address where to write the block */
+	__le16 len;		/* length of the data only, in bytes */
 	char data[0];		/* data to be written */
 } __attribute__ ((packed));
=20
@@ -131,9 +131,9 @@ struct dblock {
  * items with matching ID should be written.
  */
 struct pdr {
-	__le32 _id;		/* record ID */
-	__le32 _addr;		/* adapter address where to write the data */
-	__le32 _len;		/* expected length of the data, in bytes */
+	__le32 id;		/* record ID */
+	__le32 addr;		/* adapter address where to write the data */
+	__le32 len;		/* expected length of the data, in bytes */
 	char next[0];		/* next PDR starts here */
 } __attribute__ ((packed));
=20
@@ -144,8 +144,8 @@ struct pdr {
  * be plugged into the secondary firmware.
  */
 struct pdi {
-	__le16 _len;		/* length of ID and data, in words */
-	__le16 _id;		/* record ID */
+	__le16 len;		/* length of ID and data, in words */
+	__le16 id;		/* record ID */
 	char data[0];		/* plug data */
 } __attribute__ ((packed));
=20
@@ -154,44 +154,44 @@ struct pdi {
 static inline u32
 dblock_addr(const struct dblock *blk)
 {
-	return le32_to_cpu(blk->_addr);
+	return le32_to_cpu(blk->addr);
 }
=20
 static inline u32
 dblock_len(const struct dblock *blk)
 {
-	return le16_to_cpu(blk->_len);
+	return le16_to_cpu(blk->len);
 }
=20
 static inline u32
 pdr_id(const struct pdr *pdr)
 {
-	return le32_to_cpu(pdr->_id);
+	return le32_to_cpu(pdr->id);
 }
=20
 static inline u32
 pdr_addr(const struct pdr *pdr)
 {
-	return le32_to_cpu(pdr->_addr);
+	return le32_to_cpu(pdr->addr);
 }
=20
 static inline u32
 pdr_len(const struct pdr *pdr)
 {
-	return le32_to_cpu(pdr->_len);
+	return le32_to_cpu(pdr->len);
 }
=20
 static inline u32
 pdi_id(const struct pdi *pdi)
 {
-	return le16_to_cpu(pdi->_id);
+	return le16_to_cpu(pdi->id);
 }
=20
 /* Return length of the data only, in bytes */
 static inline u32
 pdi_len(const struct pdi *pdi)
 {
-	return 2 * (le16_to_cpu(pdi->_len) - 1);
+	return 2 * (le16_to_cpu(pdi->len) - 1);
 }
=20
=20



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting langua=
ge
that extends applications into web and mobile media. Attend the live webc=
ast
and join the prime developer group breaking into this new coding territor=
y!
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D110944&bid=3D241720&dat=3D=
121642
