From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/2] openvswitch: Honor dp_ifindex, when specified,
	for vport lookup by name.
Date: Wed,  7 Mar 2012 18:56:07 -0800
Message-ID: <1331175368-32692-2-git-send-email-jesse@nicira.com>
References: <1331175368-32692-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1331175368-32692-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>

When OVS_VPORT_ATTR_NAME is specified and dp_ifindex is nonzero, the
logical behavior would be for the vport name lookup scope to be limited
to the specified datapath, but in fact the dp_ifindex value was ignored.
This commit causes the search scope to be honored.

Signed-off-by: Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/datapath.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index ce64c18..2c03050 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1521,6 +1521,9 @@ static struct vport *lookup_vport(struct ovs_header *ovs_header,
 		vport = ovs_vport_locate(nla_data(a[OVS_VPORT_ATTR_NAME]));
 		if (!vport)
 			return ERR_PTR(-ENODEV);
+		if (ovs_header->dp_ifindex &&
+		    ovs_header->dp_ifindex != get_dpifindex(vport->dp))
+			return ERR_PTR(-ENODEV);
 		return vport;
 	} else if (a[OVS_VPORT_ATTR_PORT_NO]) {
 		u32 port_no = nla_get_u32(a[OVS_VPORT_ATTR_PORT_NO]);
-- 
1.7.5.4
