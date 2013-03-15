From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 4/5] openvswitch: Change ENOENT return
	value to ENODEV in lookup_vport().
Date: Fri, 15 Mar 2013 10:38:50 -0700
Message-ID: <1363369131-16830-5-git-send-email-jesse@nicira.com>
References: <1363369131-16830-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1363369131-16830-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

From: Jarno Rajahalme <jarno.rajahalme-OYasijW0DpE@public.gmane.org>

This reduces the number of valid "no such device" error values that
need special attention by the caller.

Userspace code will need to keep on checking for both ENODEV and
ENOENT as long as older kernel modules are around.

Signed-off-by: Jarno Rajahalme <jarno.rajahalme-OYasijW0DpE@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/datapath.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index f996db3..f9d2438 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1628,7 +1628,7 @@ static struct vport *lookup_vport(struct net *net,
 
 		vport = ovs_vport_rtnl_rcu(dp, port_no);
 		if (!vport)
-			return ERR_PTR(-ENOENT);
+			return ERR_PTR(-ENODEV);
 		return vport;
 	} else
 		return ERR_PTR(-EINVAL);
-- 
1.7.10.4
