From: Patrick Mullaney <pmullaney@novell.com>
Subject: [PATCH 3/3] macvlan: use rtnl_link_ops->dellink during unregister
	notications
Date: Thu, 14 Jan 2010 16:53:18 -0500
Message-ID: <20100114215318.4958.97684.stgit@mimic.site>
References: <20100114215058.4958.87746.stgit@mimic.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kaber@trash.net, arnd@arndb.de,
	netdev@vger.kernel.org
To: alacrityvm-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20100114215058.4958.87746.stgit@mimic.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Different macvlan device types will need to release resources in
their own type specific dellink operation. This change ensures they
will for unregister notifications on the lower level device.

Signed-off-by: Patrick Mullaney <pmullaney@novell.com>
---

 drivers/net/macvlan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 94bb135..a57faaa 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -570,7 +570,7 @@ static int macvlan_device_event(struct notifier_block *unused,
 		break;
 	case NETDEV_UNREGISTER:
 		list_for_each_entry_safe(vlan, next, &port->vlans, list)
-			macvlan_dellink(vlan->dev);
+			vlan->dev->rtnl_link_ops->dellink(vlan->dev);
 		break;
 	}
 	return NOTIFY_DONE;

