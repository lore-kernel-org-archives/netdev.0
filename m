From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: [PATCH] USB Pegasus driver - avoid a potential
	NULL pointer dereference.
Date: Sun, 29 Jul 2007 00:19:02 +0200
Message-ID: <200707290019.02591.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <greg@kroah.com>,
	Jesper Juhl <jesper.juhl@gmail.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-usb-devel@lists.sourceforge.net
To: Petko Manolov <petkan@users.sourceforge.net>
Return-path: <linux-usb-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-usb-devel>
List-Post: <mailto:linux-usb-devel@lists.sourceforge.net>
List-Help: <mailto:linux-usb-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: linux-usb-devel-bounces@lists.sourceforge.net
Errors-To: linux-usb-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hello,

This patch makes sure we don't dereference a NULL pointer in 
drivers/net/usb/pegasus.c::write_bulk_callback() in the initial 
struct net_device *net = pegasus->net; assignment.
The existing code checks if 'pegasus' is NULL and bails out if 
it is, so we better not touch that pointer until after that check.

Please consider merging.


Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
---

 drivers/net/usb/pegasus.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index a05fd97..04cba6b 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -768,11 +768,13 @@ done:
 static void write_bulk_callback(struct urb *urb)
 {
 	pegasus_t *pegasus = urb->context;
-	struct net_device *net = pegasus->net;
+	struct net_device *net;
 
 	if (!pegasus)
 		return;
 
+	net = pegasus->net;
+
 	if (!netif_device_present(net) || !netif_running(net))
 		return;
 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
linux-usb-devel@lists.sourceforge.net
To unsubscribe, use the last form field at:
https://lists.sourceforge.net/lists/listinfo/linux-usb-devel
