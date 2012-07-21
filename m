From: Randy Dunlap <rdunlap@xenotime.net>
Subject: [PATCH] wimax: fix printk format warnings
Date: Sat, 21 Jul 2012 13:54:35 -0700
Message-ID: <500B170B.4000000@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Geert Uytterhoeven <geert@linux-m68k.org>, wimax@linuxwimax.org,
	Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>,
	linux-wimax@intel.com
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <wimax-bounces@linuxwimax.org>
List-Unsubscribe: <http://lists.linuxwimax.org/options/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.linuxwimax.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://lists.linuxwimax.org/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>

Fix printk format warnings in drivers/net/wimax/i2400m:

drivers/net/wimax/i2400m/control.c: warning: format '%zu' expects argument of type 'size_t', but argument 4 has type 'ssize_t' [-Wformat]
drivers/net/wimax/i2400m/control.c: warning: format '%zu' expects argument of type 'size_t', but argument 5 has type 'ssize_t' [-Wformat]
drivers/net/wimax/i2400m/usb-fw.c: warning: format '%zu' expects argument of type 'size_t', but argument 4 has type 'ssize_t' [-Wformat]

I don't see these warnings on x86.  The warnings that are quoted above
are from Geert's kernel build reports.

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
Cc:	Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
Cc:	linux-wimax@intel.com
Cc:	wimax@linuxwimax.org
---
 drivers/net/wimax/i2400m/control.c |    4 ++--
 drivers/net/wimax/i2400m/usb-fw.c  |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

--- lnx-35-rc7.orig/drivers/net/wimax/i2400m/control.c
+++ lnx-35-rc7/drivers/net/wimax/i2400m/control.c
@@ -130,7 +130,7 @@ ssize_t i2400m_tlv_match(const struct i2
 	    && le16_to_cpu(tlv->length) + sizeof(*tlv) != tlv_size) {
 		size_t size = le16_to_cpu(tlv->length) + sizeof(*tlv);
 		printk(KERN_WARNING "W: tlv type 0x%x mismatched because of "
-		       "size (got %zu vs %zu expected)\n",
+		       "size (got %zu vs %zd expected)\n",
 		       tlv_type, size, tlv_size);
 		return size;
 	}
@@ -235,7 +235,7 @@ const struct i2400m_tlv_hdr *i2400m_tlv_
 			break;
 		if (match > 0)
 			dev_warn(dev, "TLV type 0x%04x found with size "
-				 "mismatch (%zu vs %zu needed)\n",
+				 "mismatch (%zu vs %zd needed)\n",
 				 tlv_type, match, tlv_size);
 	}
 	return tlv;
--- lnx-35-rc7.orig/drivers/net/wimax/i2400m/usb-fw.c
+++ lnx-35-rc7/drivers/net/wimax/i2400m/usb-fw.c
@@ -212,7 +212,7 @@ ssize_t i2400mu_bus_bm_cmd_send(struct i
 	}
 	if (result != cmd_size) {		/* all was transferred? */
 		dev_err(dev, "boot-mode cmd %d: incomplete transfer "
-			"(%zu vs %zu submitted)\n",  opcode, result, cmd_size);
+			"(%zd vs %zu submitted)\n",  opcode, result, cmd_size);
 		result = -EIO;
 		goto error_cmd_size;
 	}
