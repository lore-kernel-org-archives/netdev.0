From: "Satyam Sharma" <satyam.sharma@gmail.com>
Subject: Re: Getting make net/built-in.o Error with 2.6.21.1
	Build
Date: Tue, 8 May 2007 05:55:38 +0530
Message-ID: <a781481a0705071725i1d802dfejbcdaca4ab0a1ff55@mail.gmail.com>
References: <463FB6B0.3070005@pcburn.com>
Reply-To: BlueZ development <bluez-devel@lists.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, marcel@holtmann.org,
	linux-kernel@vger.kernel.org, bluez-devel@lists.sf.net
To: chris@pcburn.com
Return-path: <bluez-devel-bounces@lists.sourceforge.net>
In-Reply-To: <463FB6B0.3070005@pcburn.com>
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

On 5/8/07, Chris Bergeron <chris@pcburn.com> wrote:
> On trying to build a 2.6.21.1 kernel using the configuration at
> http://pcburn.com/files/kernel/breaks.2.6.21.1.config I'm getting the
> following error with Networking Support -> Bluetooth Subsystem Support
> -> HIDP protocol support set to built-in:
>
>   CC      init/version.o
>   LD      init/built-in.o
>   LD      .tmp_vmlinux1
> net/built-in.o: In function `hidp_add_connection':
> (.text+0x8bb08): undefined reference to `hid_ff_init'
> make: *** [.tmp_vmlinux1] Error 1

You've got CONFIG_BT_HIDP=y there but CONFIG_USB_HID=m. The trivial
patch below solves it. To test, you can just "make oldconfig" on the
same .config that broke above and then proceed to make bzImage.

Satyam

---

Make CONFIG_BT_HIDP depend on CONFIG_USB_HID and CONFIG_HID_FF.

Signed-off-by: Satyam Sharma <ssatyam@cse.iitk.ac.in>

---

 net/bluetooth/hidp/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

---

diff -ruNp a/net/bluetooth/hidp/Kconfig b/net/bluetooth/hidp/Kconfig
--- a/net/bluetooth/hidp/Kconfig	2007-04-26 08:38:32.000000000 +0530
+++ b/net/bluetooth/hidp/Kconfig	2007-05-08 05:40:58.000000000 +0530
@@ -1,6 +1,6 @@
 config BT_HIDP
 	tristate "HIDP protocol support"
-	depends on BT && BT_L2CAP && INPUT
+	depends on BT && BT_L2CAP && INPUT && USB_HID && HID_FF
 	select HID
 	help
 	  HIDP (Human Interface Device Protocol) is a transport layer

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
