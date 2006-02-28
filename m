From: Carlos Martin <carlos@cmartin.tk>
Subject: [PATCH 3/7] acxsm: Create struct acx_ops
Date: Tue, 28 Feb 2006 17:30:14 +0100
Message-ID: <11411442144096-git-send-email-carlos@cmartin.tk>
References: <1141144213577-git-send-email-carlos@cmartin.tk>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Denis Vlasenko <vda@ilport.com.ua>,
	acx100-devel@lists.sourceforge.net,
	Christoph Hellwig <hch@infradead.org>,
	Carlos Martin <carlos@kiopa. (none)>,
	Carlos Martin <carlos@cmartin.tk>
Return-path: <acx100-devel-admin@lists.sourceforge.net>
In-Reply-To: <1141144213577-git-send-email-carlos@cmartin.tk>
To: netdev@vger.kernel.org
Sender: acx100-devel-admin@lists.sourceforge.net
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

struct acx_ops is where the device-specific functions go. This allows
us to call these functions from the acx-common.ko module without
creating recursive dependencies.

Signed-off-by: Carlos Martin <carlos@cmartin.tk>

---

 acx_struct.h |   32 ++++++++++++++++++++++++++++----
 1 files changed, 28 insertions(+), 4 deletions(-)

fe7e63091292e78cb523c8060b267c0faeb3b898
diff --git a/acx_struct.h b/acx_struct.h
index 93495e0..227b6e3 100644
--- a/acx_struct.h
+++ b/acx_struct.h
@@ -87,6 +87,31 @@ enum { acx_debug =3D 0 };
 #define SCHEDULE_WORK schedule_work
 #define FLUSH_SCHEDULED_WORK flush_scheduled_work
=20
+/***********************************************************************
+** Chip-specific functions get set here.
+*/
+
+struct acx_ops {
+	int (*create_dma_regions)(acx_device_t *);
+	void (*delete_dma_regions)(acx_device_t *);
+
+#if ACX_DEBUG
+	int (*issue_cmd)(acx_device_t *adev, unsigned cmd, void *param,
+			 unsigned len, unsigned cmd_timeout, const char *cmdstr);
+#else
+	int (*issue_cmd)(acx_device_t *adev, unsigned cmd, void *param,
+			 unsigned len, unsigned cmd_timeout);
+#endif /* ACX_DEBUG */
+	tx_t* (*alloc_tx)(acx_device_t *adev);
+	void (*dealloc_tx)(tx_t *tx_opaque);
+
+	void* (*get_txbuf)(acx_device_t *adev, tx_t *tx_opaque);
+	void (*tx_data)(acx_device_t *adev, tx_t *tx_opaque, int len);
+
+	int (*write_phy_reg)(acx_device_t *adev, u32 reg, u8 value);
+	int (*read_phy_reg)(acx_device_t *adev, u32 reg, u8 *charbuf);
+};
+
=20
 /***********************************************************************
 ** Constants
@@ -105,10 +130,6 @@ enum { acx_debug =3D 0 };
 #define DEVTYPE_PCI		0
 #define DEVTYPE_USB		1
=20
-#if !defined(CONFIG_ACX_PCI) && !defined(CONFIG_ACX_USB)
-#error Driver must include PCI and/or USB support. You selected neither.
-#endif
-
 #if defined(CONFIG_ACX_PCI)
  #if !defined(CONFIG_ACX_USB)
   #define IS_PCI(adev)	1
@@ -1198,6 +1219,9 @@ struct acx_device {
 	/*** Linux network device ***/
 	struct net_device	*ndev;		/* pointer to linux netdevice */
=20
+	/* Chip-specific functions */
+	struct acx_ops		ops;
+
 	/*** Device statistics ***/
 	struct net_device_stats	stats;		/* net device statistics */
 #ifdef WIRELESS_EXT
--=20
1.2.1.g62a4




-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
