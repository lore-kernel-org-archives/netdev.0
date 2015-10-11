From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next] bridge: vlan: enforce no pvid flag in
	vlan ranges
Date: Sun, 11 Oct 2015 12:49:56 +0200
Message-ID: <1444560596-7140-1-git-send-email-razor@blackwall.org>
References: <20151011071208.GA2188@nanopsycho.orion>
Cc: jiri@resnulli.us, Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	bridge@lists.linux-foundation.org, eladr@mellanox.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20151011071208.GA2188@nanopsycho.orion>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Currently it's possible for someone to send a vlan range to the kernel
with the pvid flag set which will result in the pvid bouncing from a
vlan to vlan and isn't correct, it also introduces problems for hardware
where it doesn't make sense having more than 1 pvid. iproute2 already
enforces this, so let's enforce it on kernel-side as well.

Reported-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_netlink.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index d78b4429505a..02b17b53e9a6 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -524,6 +524,9 @@ static int br_afspec(struct net_bridge *br,
 			if (vinfo_start)
 				return -EINVAL;
 			vinfo_start = vinfo;
+			/* don't allow range of pvids */
+			if (vinfo_start->flags & BRIDGE_VLAN_INFO_PVID)
+				return -EINVAL;
 			continue;
 		}
 
-- 
2.4.3
