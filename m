From: Dave Young <hidave.darkstar@gmail.com>
Subject: [PATCH 2/2] bluetooth : do not move child device
	other than rfcomm
Date: Mon, 18 Feb 2008 15:58:05 +0800
Message-ID: <20080218075805.GB5940@darkstar.te-china.tietoenator.com>
Reply-To: BlueZ development <bluez-devel@lists.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bluez-devel@lists.sf.net, linux-kernel@vger.kernel.org
To: marcel@holtmann.org
Return-path: <bluez-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=bluez-devel>
List-Post: <mailto:bluez-devel@lists.sourceforge.net>
List-Help: <mailto:bluez-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: bluez-devel-bounces@lists.sourceforge.net
Errors-To: bluez-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

hci conn child devices other than rfcomm tty should not be moved here.
This is my lost, thanks for Barnaby's reporting and testing.

Signed-off-by: Dave Young <hidave.darkstar@gmail.com> 

---
net/bluetooth/hci_sysfs.c |   13 ++++++-------
1 file changed, 6 insertions(+), 7 deletions(-)

diff -upr linux/net/bluetooth/hci_sysfs.c linux.new/net/bluetooth/hci_sysfs.c
--- linux/net/bluetooth/hci_sysfs.c	2008-02-16 06:38:56.000000000 +0800
+++ linux.new/net/bluetooth/hci_sysfs.c	2008-02-17 15:45:15.000000000 +0800
@@ -320,15 +320,14 @@ void hci_conn_add_sysfs(struct hci_conn 
 	queue_work(btaddconn, &conn->work);
 }
 
+/*
+ * The rfcomm tty device will possibly retain even when conn
+ * is down, and sysfs doesn't support move zombie device,
+ * so we should move the device before conn device is destroyed.
+ */
 static int __match_tty(struct device *dev, void *data)
 {
-	/* The rfcomm tty device will possibly retain even when conn
-	 * is down, and sysfs doesn't support move zombie device,
-	 * so we should move the device before conn device is destroyed.
-	 * Due to the only child device of hci_conn dev is rfcomm
-	 * tty_dev, here just return 1
-	 */
-	return 1;
+	return !strncmp(dev->bus_id, "rfcomm", 6);
 }
 
 static void del_conn(struct work_struct *work)

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
