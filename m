From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 04/12] openvswitch: Added (unsigned long
	long) cast in printf
Date: Fri, 16 May 2014 14:07:31 -0700
Message-ID: <1400274459-56304-5-git-send-email-jesse@nicira.com>
References: <1400274459-56304-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Daniele Di Proietto <daniele.di.proietto-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1400274459-56304-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Daniele Di Proietto <daniele.di.proietto-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

This is necessary, since u64 is not unsigned long long
in all architectures: u64 could be also uint64_t.

Signed-off-by: Daniele Di Proietto <daniele.di.proietto-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/flow_netlink.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 5517bd6..1b22ad2 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -216,14 +216,14 @@ static bool match_validate(const struct sw_flow_match *match,
 	if ((key_attrs & key_expected) != key_expected) {
 		/* Key attributes check failed. */
 		OVS_NLERR("Missing expected key attributes (key_attrs=%llx, expected=%llx).\n",
-				key_attrs, key_expected);
+				(unsigned long long)key_attrs, (unsigned long long)key_expected);
 		return false;
 	}
 
 	if ((mask_attrs & mask_allowed) != mask_attrs) {
 		/* Mask attributes check failed. */
 		OVS_NLERR("Contain more than allowed mask fields (mask_attrs=%llx, mask_allowed=%llx).\n",
-				mask_attrs, mask_allowed);
+				(unsigned long long)mask_attrs, (unsigned long long)mask_allowed);
 		return false;
 	}
 
-- 
1.9.1
