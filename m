From: Milos Vyletel <milos.vyletel@gmail.com>
Subject: [patch net-next 1/5] ipv6: align sysctl table creation code with ipv4
Date: Tue, 10 Jun 2014 12:19:09 -0400
Message-ID: <1402417153-2551-2-git-send-email-milos.vyletel@gmail.com>
References: <1402417153-2551-1-git-send-email-milos.vyletel@gmail.com>
Cc: Milos Vyletel <milos.vyletel@gmail.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	linux-kernel@vger.kernel.org (open list)
To: davem@davemloft.net, amwang@redhat.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1402417153-2551-1-git-send-email-milos.vyletel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use ADDRCONF_SYSCTL* macros to define sysctl table. This is first step
to align ipv6 and ipv4 sysctl code.

Signed-off-by: Milos Vyletel <milos.vyletel@gmail.com>
---
 net/ipv6/addrconf.c | 300 ++++++++++++----------------------------------------
 1 file changed, 66 insertions(+), 234 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 5667b30..dbacca4 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4917,6 +4917,27 @@ int addrconf_sysctl_proxy_ndp(struct ctl_table *ctl, int write,
 	return ret;
 }
 
+#define ADDRCONF_SYSCTL_ENTRY(name, var, mval, proc) \
+	{ \
+		.procname	= #name, \
+		.data		= (void *)&ipv6_devconf + \
+				offsetof(struct ipv6_devconf, var), \
+		.maxlen		= sizeof(int), \
+		.mode		= mval, \
+		.proc_handler	= proc, \
+	}
+
+#define ADDRCONF_SYSCTL_RW_ENTRY(name) \
+	ADDRCONF_SYSCTL_ENTRY(name, name, 0644, proc_dointvec)
+
+#define ADDRCONF_SYSCTL_RO_ENTRY(name) \
+	ADDRCONF_SYSCTL_ENTRY(name, name, 0444, proc_dointvec)
+
+#define ADDRCONF_SYSCTL_COMPLEX_ENTRY(name, proc) \
+	ADDRCONF_SYSCTL_ENTRY(name, name, 0644, proc)
+
+#define ADDRCONF_SYSCTL_CUSTOM_ENTRY(name, var, proc) \
+	ADDRCONF_SYSCTL_ENTRY(name, var, 0644, proc)
 
 static struct addrconf_sysctl_table
 {
@@ -4925,248 +4946,59 @@ static struct addrconf_sysctl_table
 } addrconf_sysctl __read_mostly = {
 	.sysctl_header = NULL,
 	.addrconf_vars = {
-		{
-			.procname	= "forwarding",
-			.data		= &ipv6_devconf.forwarding,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= addrconf_sysctl_forward,
-		},
-		{
-			.procname	= "hop_limit",
-			.data		= &ipv6_devconf.hop_limit,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname	= "mtu",
-			.data		= &ipv6_devconf.mtu6,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname	= "accept_ra",
-			.data		= &ipv6_devconf.accept_ra,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname	= "accept_redirects",
-			.data		= &ipv6_devconf.accept_redirects,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname	= "autoconf",
-			.data		= &ipv6_devconf.autoconf,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname	= "dad_transmits",
-			.data		= &ipv6_devconf.dad_transmits,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname	= "router_solicitations",
-			.data		= &ipv6_devconf.rtr_solicits,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname	= "router_solicitation_interval",
-			.data		= &ipv6_devconf.rtr_solicit_interval,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec_jiffies,
-		},
-		{
-			.procname	= "router_solicitation_delay",
-			.data		= &ipv6_devconf.rtr_solicit_delay,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec_jiffies,
-		},
-		{
-			.procname	= "force_mld_version",
-			.data		= &ipv6_devconf.force_mld_version,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname	= "mldv1_unsolicited_report_interval",
-			.data		=
-				&ipv6_devconf.mldv1_unsolicited_report_interval,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec_ms_jiffies,
-		},
-		{
-			.procname	= "mldv2_unsolicited_report_interval",
-			.data		=
-				&ipv6_devconf.mldv2_unsolicited_report_interval,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec_ms_jiffies,
-		},
-		{
-			.procname	= "use_tempaddr",
-			.data		= &ipv6_devconf.use_tempaddr,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname	= "temp_valid_lft",
-			.data		= &ipv6_devconf.temp_valid_lft,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname	= "temp_prefered_lft",
-			.data		= &ipv6_devconf.temp_prefered_lft,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname	= "regen_max_retry",
-			.data		= &ipv6_devconf.regen_max_retry,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname	= "max_desync_factor",
-			.data		= &ipv6_devconf.max_desync_factor,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname	= "max_addresses",
-			.data		= &ipv6_devconf.max_addresses,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname	= "accept_ra_defrtr",
-			.data		= &ipv6_devconf.accept_ra_defrtr,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname	= "accept_ra_pinfo",
-			.data		= &ipv6_devconf.accept_ra_pinfo,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
+		ADDRCONF_SYSCTL_COMPLEX_ENTRY(forwarding,
+					      addrconf_sysctl_forward),
+		ADDRCONF_SYSCTL_RW_ENTRY(hop_limit),
+		ADDRCONF_SYSCTL_CUSTOM_ENTRY(mtu, mtu6, proc_dointvec),
+		ADDRCONF_SYSCTL_RW_ENTRY(accept_ra),
+		ADDRCONF_SYSCTL_RW_ENTRY(accept_redirects),
+		ADDRCONF_SYSCTL_RW_ENTRY(autoconf),
+		ADDRCONF_SYSCTL_RW_ENTRY(dad_transmits),
+		ADDRCONF_SYSCTL_CUSTOM_ENTRY(router_solicitations, rtr_solicits,
+					     proc_dointvec),
+		ADDRCONF_SYSCTL_CUSTOM_ENTRY(router_solicitation_interval,
+					     rtr_solicit_interval,
+					     proc_dointvec_jiffies),
+		ADDRCONF_SYSCTL_CUSTOM_ENTRY(router_solicitation_delay,
+					     rtr_solicit_delay,
+					     proc_dointvec_jiffies),
+		ADDRCONF_SYSCTL_RW_ENTRY(force_mld_version),
+		ADDRCONF_SYSCTL_COMPLEX_ENTRY(mldv1_unsolicited_report_interval,
+					      proc_dointvec_ms_jiffies),
+		ADDRCONF_SYSCTL_COMPLEX_ENTRY(mldv2_unsolicited_report_interval,
+					      proc_dointvec_ms_jiffies),
+		ADDRCONF_SYSCTL_RW_ENTRY(use_tempaddr),
+		ADDRCONF_SYSCTL_RW_ENTRY(temp_valid_lft),
+		ADDRCONF_SYSCTL_RW_ENTRY(temp_prefered_lft),
+		ADDRCONF_SYSCTL_RW_ENTRY(regen_max_retry),
+		ADDRCONF_SYSCTL_RW_ENTRY(max_desync_factor),
+		ADDRCONF_SYSCTL_RW_ENTRY(max_addresses),
+		ADDRCONF_SYSCTL_RW_ENTRY(accept_ra_defrtr),
+		ADDRCONF_SYSCTL_RW_ENTRY(accept_ra_pinfo),
 #ifdef CONFIG_IPV6_ROUTER_PREF
-		{
-			.procname	= "accept_ra_rtr_pref",
-			.data		= &ipv6_devconf.accept_ra_rtr_pref,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname	= "router_probe_interval",
-			.data		= &ipv6_devconf.rtr_probe_interval,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec_jiffies,
-		},
+		ADDRCONF_SYSCTL_RW_ENTRY(accept_ra_rtr_pref),
+		ADDRCONF_SYSCTL_CUSTOM_ENTRY(router_probe_interval,
+					     rtr_probe_interval,
+					     proc_dointvec_jiffies),
 #ifdef CONFIG_IPV6_ROUTE_INFO
-		{
-			.procname	= "accept_ra_rt_info_max_plen",
-			.data		= &ipv6_devconf.accept_ra_rt_info_max_plen,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
+		ADDRCONF_SYSCTL_RW_ENTRY(accept_ra_rt_info_max_plen),
 #endif
 #endif
-		{
-			.procname	= "proxy_ndp",
-			.data		= &ipv6_devconf.proxy_ndp,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= addrconf_sysctl_proxy_ndp,
-		},
-		{
-			.procname	= "accept_source_route",
-			.data		= &ipv6_devconf.accept_source_route,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
+		ADDRCONF_SYSCTL_COMPLEX_ENTRY(proxy_ndp,
+					      addrconf_sysctl_proxy_ndp),
+		ADDRCONF_SYSCTL_RW_ENTRY(accept_source_route),
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
-		{
-			.procname       = "optimistic_dad",
-			.data           = &ipv6_devconf.optimistic_dad,
-			.maxlen         = sizeof(int),
-			.mode           = 0644,
-			.proc_handler   = proc_dointvec,
-
-		},
+		ADDRCONF_SYSCTL_RW_ENTRY(optimistic_dad),
 #endif
 #ifdef CONFIG_IPV6_MROUTE
-		{
-			.procname	= "mc_forwarding",
-			.data		= &ipv6_devconf.mc_forwarding,
-			.maxlen		= sizeof(int),
-			.mode		= 0444,
-			.proc_handler	= proc_dointvec,
-		},
+		ADDRCONF_SYSCTL_RO_ENTRY(mc_forwarding),
 #endif
-		{
-			.procname	= "disable_ipv6",
-			.data		= &ipv6_devconf.disable_ipv6,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= addrconf_sysctl_disable,
-		},
-		{
-			.procname	= "accept_dad",
-			.data		= &ipv6_devconf.accept_dad,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
-		},
-		{
-			.procname       = "force_tllao",
-			.data           = &ipv6_devconf.force_tllao,
-			.maxlen         = sizeof(int),
-			.mode           = 0644,
-			.proc_handler   = proc_dointvec
-		},
-		{
-			.procname       = "ndisc_notify",
-			.data           = &ipv6_devconf.ndisc_notify,
-			.maxlen         = sizeof(int),
-			.mode           = 0644,
-			.proc_handler   = proc_dointvec
-		},
-		{
-			.procname	= "suppress_frag_ndisc",
-			.data		= &ipv6_devconf.suppress_frag_ndisc,
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec
-		},
+		ADDRCONF_SYSCTL_COMPLEX_ENTRY(disable_ipv6,
+					      addrconf_sysctl_disable),
+		ADDRCONF_SYSCTL_RW_ENTRY(accept_dad),
+		ADDRCONF_SYSCTL_RW_ENTRY(force_tllao),
+		ADDRCONF_SYSCTL_RW_ENTRY(ndisc_notify),
+		ADDRCONF_SYSCTL_RW_ENTRY(suppress_frag_ndisc),
 		{
 			/* sentinel */
 		}
-- 
1.9.0
