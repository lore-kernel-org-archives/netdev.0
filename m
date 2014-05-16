From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 10/12] openvswitch: Fix output of SCTP
	mask.
Date: Fri, 16 May 2014 14:07:37 -0700
Message-ID: <1400274459-56304-11-git-send-email-jesse@nicira.com>
References: <1400274459-56304-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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

From: Jarno Rajahalme <jrajahalme-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>

The 'output' argument of the ovs_nla_put_flow() is the one from which
the bits are written to the netlink attributes.  For SCTP we
accidentally used the bits from the 'swkey' instead.  This caused the
mask attributes to include the bits from the actual flow key instead
of the mask.

Signed-off-by: Jarno Rajahalme <jrajahalme-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Acked-by: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/flow_netlink.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 84caa99..32a725c 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -1059,11 +1059,11 @@ int ovs_nla_put_flow(const struct sw_flow_key *swkey,
 				goto nla_put_failure;
 			sctp_key = nla_data(nla);
 			if (swkey->eth.type == htons(ETH_P_IP)) {
-				sctp_key->sctp_src = swkey->ipv4.tp.src;
-				sctp_key->sctp_dst = swkey->ipv4.tp.dst;
+				sctp_key->sctp_src = output->ipv4.tp.src;
+				sctp_key->sctp_dst = output->ipv4.tp.dst;
 			} else if (swkey->eth.type == htons(ETH_P_IPV6)) {
-				sctp_key->sctp_src = swkey->ipv6.tp.src;
-				sctp_key->sctp_dst = swkey->ipv6.tp.dst;
+				sctp_key->sctp_src = output->ipv6.tp.src;
+				sctp_key->sctp_dst = output->ipv6.tp.dst;
 			}
 		} else if (swkey->eth.type == htons(ETH_P_IP) &&
 			   swkey->ip.proto == IPPROTO_ICMP) {
-- 
1.9.1
