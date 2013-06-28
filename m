From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH next] xen: Convert printks to pr_<level>
Date: Fri, 28 Jun 2013 04:31:44 -0700
Message-ID: <1372419104.2060.54.camel@joe-AO722>
References: <1372395469.2060.36.camel@joe-AO722>
	<20130628080250.GA16643@zion.uk.xensource.com>
	<1372414901.2060.44.camel@joe-AO722>
	<20130628103605.GE16643@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, xen-devel@lists.xensource.com,
	Ian Campbell <ian.campbell@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"virtualization@lists.osdl.org" <virtualization@lists.linux-foundation.org>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20130628103605.GE16643@zion.uk.xensource.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-06-28 at 11:36 +0100, Wei Liu wrote:
> I can clean up the rest in xen-netback after your previous patch goes
> in.

Here's a suggested change for drivers/net

Convert printk to pr_<level>
Add missing newlines to pr_debug
Remove duplicate "s: " __func__
Reflow to 80 columns

---

 drivers/net/xen-netback/xenbus.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 04bd860..1fe48fe3 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -130,7 +130,7 @@ static int netback_probe(struct xenbus_device *dev,
 			    "feature-split-event-channels",
 			    "%u", separate_tx_rx_irq);
 	if (err)
-		pr_debug("Error writing feature-split-event-channels");
+		pr_debug("Error writing feature-split-event-channels\n");
 
 	err = xenbus_switch_state(dev, XenbusStateInitWait);
 	if (err)
@@ -145,7 +145,7 @@ abort_transaction:
 	xenbus_transaction_end(xbt, 1);
 	xenbus_dev_fatal(dev, err, "%s", message);
 fail:
-	pr_debug("failed");
+	pr_debug("failed\n");
 	netback_remove(dev);
 	return err;
 }
@@ -228,15 +228,14 @@ static void frontend_changed(struct xenbus_device *dev,
 {
 	struct backend_info *be = dev_get_drvdata(&dev->dev);
 
-	pr_debug("frontend state %s", xenbus_strstate(frontend_state));
+	pr_debug("frontend state %s\n", xenbus_strstate(frontend_state));
 
 	be->frontend_state = frontend_state;
 
 	switch (frontend_state) {
 	case XenbusStateInitialising:
 		if (dev->state == XenbusStateClosed) {
-			printk(KERN_INFO "%s: %s: prepare for reconnect\n",
-			       __func__, dev->nodename);
+			pr_info("%s: prepare for reconnect\n", dev->nodename);
 			xenbus_switch_state(dev, XenbusStateInitWait);
 		}
 		break;
