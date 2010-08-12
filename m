From: Greg KH <gregkh@suse.de>
Subject: [46/54] xen: netfront: explicitly generate arp_notify
	event after migration.
Date: Wed, 11 Aug 2010 17:01:01 -0700
Message-ID: <20100812000127.502018592@clark.site>
References: <20100812000249.GA30948@kroah.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, xen-devel@lists.xensource.com,
	Ian Campbell <ian.campbell@citrix.com>, torvalds@linux-foundation.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	akpm@linux-foundation.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	stable-review@kernel.org, alan@lxorguk.ukuu.org.uk
To: linux-kernel@vger.kernel.org,
 stable@kernel.org
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <20100812000249.GA30948@kroah.com>
List-Unsubscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

2.6.34-stable review patch.  If anyone has any objections, please let us know.

------------------

From: Ian Campbell <Ian.Campbell@citrix.com>

commit 592970675c9522bde588b945388c7995c8b51328 upstream.

Use newly introduced netif_notify_peers() method to ensure a gratuitous ARP is
generated after a migration.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: xen-devel@lists.xensource.com
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 drivers/net/xen-netfront.c |    1 +
 1 file changed, 1 insertion(+)

--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1621,6 +1621,7 @@ static void backend_changed(struct xenbu
 		if (xennet_connect(netdev) != 0)
 			break;
 		xenbus_switch_state(dev, XenbusStateConnected);
+		netif_notify_peers(netdev);
 		break;
 
 	case XenbusStateClosing:
