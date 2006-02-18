From: Carlos Martin <carlos@cmartin.tk>
Subject: From: Carlos Martín <carlos@cmartin.tk>
Date: Sat, 18 Feb 2006 23:35:21 +0100
Message-ID: <11403021213131-git-send-email-carlos@cmartin.tk>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: acx100-devel@lists.sourceforge.net,
	Carlos Martin <carlos@cmartin.tk>
Return-path: <acx100-devel-admin@lists.sourceforge.net>
In-Reply-To: 
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

[PATCH] acxsm: Fix Kconfig option check

This check never actually worked because CONFIG_ACX_{ACX,USB} are
tristate. With Adrian Bunk's patch to the Kconfig, this works with the
_BOOL hidden Kconfig options.
Also update error message adding that this shouldn't happen anymore.

Signed-off-by: Carlos Martin <carlos@cmartin.tk>
---

 acx_struct.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/acx_struct.h b/acx_struct.h
index 93495e0..3237974 100644
--- a/acx_struct.h
+++ b/acx_struct.h
@@ -105,8 +105,9 @@ enum { acx_debug =3D 0 };
 #define DEVTYPE_PCI		0
 #define DEVTYPE_USB		1
=20
-#if !defined(CONFIG_ACX_PCI) && !defined(CONFIG_ACX_USB)
+#if !defined(CONFIG_ACX_PCI_BOOL) && !defined(CONFIG_ACX_USB_BOOL)
 #error Driver must include PCI and/or USB support. You selected neither.
+#error This really should not happen anymore. Please report.
 #endif
=20
 #if defined(CONFIG_ACX_PCI)



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
