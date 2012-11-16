From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 15/17] net: Enable some sysctls that are safe for the
	userns root
Date: Fri, 16 Nov 2012 05:03:10 -0800
Message-ID: <1353070992-5552-15-git-send-email-ebiederm@xmission.com>
References: <87d2zd8zwn.fsf@xmission.com>
	<1353070992-5552-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353070992-5552-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

- Enable the per device ipv4 sysctls:
   net/ipv4/conf/<if>/forwarding
   net/ipv4/conf/<if>/mc_forwarding
   net/ipv4/conf/<if>/accept_redirects
   net/ipv4/conf/<if>/secure_redirects
   net/ipv4/conf/<if>/shared_media
   net/ipv4/conf/<if>/rp_filter
   net/ipv4/conf/<if>/send_redirects
   net/ipv4/conf/<if>/accept_source_route
   net/ipv4/conf/<if>/accept_local
   net/ipv4/conf/<if>/src_valid_mark
   net/ipv4/conf/<if>/proxy_arp
   net/ipv4/conf/<if>/medium_id
   net/ipv4/conf/<if>/bootp_relay
   net/ipv4/conf/<if>/log_martians
   net/ipv4/conf/<if>/tag
   net/ipv4/conf/<if>/arp_filter
   net/ipv4/conf/<if>/arp_announce
   net/ipv4/conf/<if>/arp_ignore
   net/ipv4/conf/<if>/arp_accept
   net/ipv4/conf/<if>/arp_notify
   net/ipv4/conf/<if>/proxy_arp_pvlan
   net/ipv4/conf/<if>/disable_xfrm
   net/ipv4/conf/<if>/disable_policy
   net/ipv4/conf/<if>/force_igmp_version
   net/ipv4/conf/<if>/promote_secondaries
   net/ipv4/conf/<if>/route_localnet

- Enable the global ipv4 sysctl:
   net/ipv4/ip_forward

- Enable the per device ipv6 sysctls:
   net/ipv6/conf/<if>/forwarding
   net/ipv6/conf/<if>/hop_limit
   net/ipv6/conf/<if>/mtu
   net/ipv6/conf/<if>/accept_ra
   net/ipv6/conf/<if>/accept_redirects
   net/ipv6/conf/<if>/autoconf
   net/ipv6/conf/<if>/dad_transmits
   net/ipv6/conf/<if>/router_solicitations
   net/ipv6/conf/<if>/router_solicitation_interval
   net/ipv6/conf/<if>/router_solicitation_delay
   net/ipv6/conf/<if>/force_mld_version
   net/ipv6/conf/<if>/use_tempaddr
   net/ipv6/conf/<if>/temp_valid_lft
   net/ipv6/conf/<if>/temp_prefered_lft
   net/ipv6/conf/<if>/regen_max_retry
   net/ipv6/conf/<if>/max_desync_factor
   net/ipv6/conf/<if>/max_addresses
   net/ipv6/conf/<if>/accept_ra_defrtr
   net/ipv6/conf/<if>/accept_ra_pinfo
   net/ipv6/conf/<if>/accept_ra_rtr_pref
   net/ipv6/conf/<if>/router_probe_interval
   net/ipv6/conf/<if>/accept_ra_rt_info_max_plen
   net/ipv6/conf/<if>/proxy_ndp
   net/ipv6/conf/<if>/accept_source_route
   net/ipv6/conf/<if>/optimistic_dad
   net/ipv6/conf/<if>/mc_forwarding
   net/ipv6/conf/<if>/disable_ipv6
   net/ipv6/conf/<if>/accept_dad
   net/ipv6/conf/<if>/force_tllao

- Enable the global ipv6 sysctls:
   net/ipv6/bindv6only
   net/ipv6/icmp/ratelimit

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 net/ipv4/devinet.c         |    8 --------
 net/ipv6/addrconf.c        |    4 ----
 net/ipv6/icmp.c            |    7 +------
 net/ipv6/sysctl_net_ipv6.c |    4 ----
 4 files changed, 1 insertions(+), 22 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index f75f4f6..446b1b9 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1643,10 +1643,6 @@ static int __devinet_sysctl_register(struct net *net, char *dev_name,
 		t->devinet_vars[i].extra2 = net;
 	}
 
-	/* Don't export sysctls to unprivileged users */
-	if (net->user_ns != &init_user_ns)
-		t->devinet_vars[0].procname = NULL;
-
 	snprintf(path, sizeof(path), "net/ipv4/conf/%s", dev_name);
 
 	t->sysctl_header = register_net_sysctl(net, path, t->devinet_vars);
@@ -1732,10 +1728,6 @@ static __net_init int devinet_init_net(struct net *net)
 		tbl[0].data = &all->data[IPV4_DEVCONF_FORWARDING - 1];
 		tbl[0].extra1 = all;
 		tbl[0].extra2 = net;
-
-		/* Don't export sysctls to unprivileged users */
-		if (net->user_ns != &init_user_ns)
-			tbl[0].procname = NULL;
 #endif
 	}
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index b8e0a62..5f1967b 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4588,10 +4588,6 @@ static int __addrconf_sysctl_register(struct net *net, char *dev_name,
 		t->addrconf_vars[i].extra2 = net;
 	}
 
-	/* Don't export sysctls to unprivileged users */
-	if (net->user_ns != &init_user_ns)
-		t->addrconf_vars[0].procname = NULL;
-
 	snprintf(path, sizeof(path), "net/ipv6/conf/%s", dev_name);
 
 	t->sysctl_header = register_net_sysctl(net, path, t->addrconf_vars);
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index db9df8a..24d69db 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -967,14 +967,9 @@ struct ctl_table * __net_init ipv6_icmp_sysctl_init(struct net *net)
 			sizeof(ipv6_icmp_table_template),
 			GFP_KERNEL);
 
-	if (table) {
+	if (table)
 		table[0].data = &net->ipv6.sysctl.icmpv6_time;
 
-		/* Don't export sysctls to unprivileged users */
-		if (net->user_ns != &init_user_ns)
-			table[0].procname = NULL;
-	}
-
 	return table;
 }
 #endif
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index b06fd07..e85c48b 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -52,10 +52,6 @@ static int __net_init ipv6_sysctl_net_init(struct net *net)
 		goto out;
 	ipv6_table[0].data = &net->ipv6.sysctl.bindv6only;
 
-	/* Don't export sysctls to unprivileged users */
-	if (net->user_ns != &init_user_ns)
-		ipv6_table[0].procname = NULL;
-
 	ipv6_route_table = ipv6_route_sysctl_init(net);
 	if (!ipv6_route_table)
 		goto out_ipv6_table;
-- 
1.7.5.4
