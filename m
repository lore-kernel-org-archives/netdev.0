From: "Art Haas" <ahaas@airmail.net>
Subject: [PATCH] Add C99 initializers to net/ipv4/ipvs/ip_vs_ctl.c
Date: Tue, 16 Mar 2004 12:52:29 -0600
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040316185229.GA12996@artsapartment.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Wensong Zhang <wensong@gnuchina.org>,
	"David S. Miller" <davem@redhat.com>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

Hi.

Here is the first of three patches adding C99 initializers to
files in net/ipv4/ipvs. This patch is for ip_vs_ctl.c, and
is against the current BK. This patch splits a structure up
into several variables, making the code look more like
other files found in net/, and explicitly adds initializers
to an existing structure.

Art Haas

===== net/ipv4/ipvs/ip_vs_ctl.c 1.13 vs edited =====
--- 1.13/net/ipv4/ipvs/ip_vs_ctl.c	Mon Mar  8 14:01:22 2004
+++ edited/net/ipv4/ipvs/ip_vs_ctl.c	Tue Mar 16 11:49:00 2004
@@ -1384,95 +1384,223 @@
 /*
  *	IPVS sysctl table (under the /proc/sys/net/ipv4/vs/)
  */
-struct ip_vs_sysctl_table {
-	struct ctl_table_header *sysctl_header;
-	ctl_table vs_vars[NET_IPV4_VS_LAST];
-	ctl_table vs_dir[2];
-	ctl_table ipv4_dir[2];
-	ctl_table root_dir[2];
-};
 
-static struct ip_vs_sysctl_table ipv4_vs_table = {
-	NULL,
-	{{NET_IPV4_VS_AMEMTHRESH, "amemthresh",
-	  &sysctl_ip_vs_amemthresh, sizeof(int), 0644, NULL,
-	  &proc_dointvec},
+static struct ctl_table vs_vars[] = {
+	{
+		.ctl_name	= NET_IPV4_VS_AMEMTHRESH,
+		.procname	= "amemthresh",
+		.data		= &sysctl_ip_vs_amemthresh,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
 #ifdef CONFIG_IP_VS_DEBUG
-	 {NET_IPV4_VS_DEBUG_LEVEL, "debug_level",
-	  &sysctl_ip_vs_debug_level, sizeof(int), 0644, NULL,
-	  &proc_dointvec},
+	{
+		.ctl_name	= NET_IPV4_VS_DEBUG_LEVEL,
+		.procname	= "debug_level",
+		.data		= &sysctl_ip_vs_debug_level,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
 #endif
-	 {NET_IPV4_VS_AMDROPRATE, "am_droprate",
-	  &sysctl_ip_vs_am_droprate, sizeof(int), 0644, NULL,
-	  &proc_dointvec},
-	 {NET_IPV4_VS_DROP_ENTRY, "drop_entry",
-	  &sysctl_ip_vs_drop_entry, sizeof(int), 0644, NULL,
-	  &proc_do_defense_mode},
-	 {NET_IPV4_VS_DROP_PACKET, "drop_packet",
-	  &sysctl_ip_vs_drop_packet, sizeof(int), 0644, NULL,
-	  &proc_do_defense_mode},
-	 {NET_IPV4_VS_SECURE_TCP, "secure_tcp",
-	  &sysctl_ip_vs_secure_tcp, sizeof(int), 0644, NULL,
-	  &proc_do_defense_mode},
+	{
+		.ctl_name	= NET_IPV4_VS_AMDROPRATE,
+		.procname	= "am_droprate",
+		.data		= &sysctl_ip_vs_am_droprate,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+	{
+		.ctl_name	= NET_IPV4_VS_DROP_ENTRY,
+		.procname	= "drop_entry",
+		.data		= &sysctl_ip_vs_drop_entry,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_do_defense_mode,
+	},
+	{
+		.ctl_name	= NET_IPV4_VS_DROP_PACKET,
+		.procname	= "drop_packet",
+		.data		= &sysctl_ip_vs_drop_packet,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_do_defense_mode,
+	},
+	{
+		.ctl_name	= NET_IPV4_VS_SECURE_TCP,
+		.procname	= "secure_tcp",
+		.data		= &sysctl_ip_vs_secure_tcp,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_do_defense_mode,
+	},
 #if 0
-	 {NET_IPV4_VS_TO_ES, "timeout_established",
-	  &vs_timeout_table_dos.timeout[IP_VS_S_ESTABLISHED],
-	  sizeof(int), 0644, NULL, &proc_dointvec_jiffies},
-	 {NET_IPV4_VS_TO_SS, "timeout_synsent",
-	  &vs_timeout_table_dos.timeout[IP_VS_S_SYN_SENT],
-	  sizeof(int), 0644, NULL, &proc_dointvec_jiffies},
-	 {NET_IPV4_VS_TO_SR, "timeout_synrecv",
-	  &vs_timeout_table_dos.timeout[IP_VS_S_SYN_RECV],
-	  sizeof(int), 0644, NULL, &proc_dointvec_jiffies},
-	 {NET_IPV4_VS_TO_FW, "timeout_finwait",
-	  &vs_timeout_table_dos.timeout[IP_VS_S_FIN_WAIT],
-	  sizeof(int), 0644, NULL, &proc_dointvec_jiffies},
-	 {NET_IPV4_VS_TO_TW, "timeout_timewait",
-	  &vs_timeout_table_dos.timeout[IP_VS_S_TIME_WAIT],
-	  sizeof(int), 0644, NULL, &proc_dointvec_jiffies},
-	 {NET_IPV4_VS_TO_CL, "timeout_close",
-	  &vs_timeout_table_dos.timeout[IP_VS_S_CLOSE],
-	  sizeof(int), 0644, NULL, &proc_dointvec_jiffies},
-	 {NET_IPV4_VS_TO_CW, "timeout_closewait",
-	  &vs_timeout_table_dos.timeout[IP_VS_S_CLOSE_WAIT],
-	  sizeof(int), 0644, NULL, &proc_dointvec_jiffies},
-	 {NET_IPV4_VS_TO_LA, "timeout_lastack",
-	  &vs_timeout_table_dos.timeout[IP_VS_S_LAST_ACK],
-	  sizeof(int), 0644, NULL, &proc_dointvec_jiffies},
-	 {NET_IPV4_VS_TO_LI, "timeout_listen",
-	  &vs_timeout_table_dos.timeout[IP_VS_S_LISTEN],
-	  sizeof(int), 0644, NULL, &proc_dointvec_jiffies},
-	 {NET_IPV4_VS_TO_SA, "timeout_synack",
-	  &vs_timeout_table_dos.timeout[IP_VS_S_SYNACK],
-	  sizeof(int), 0644, NULL, &proc_dointvec_jiffies},
-	 {NET_IPV4_VS_TO_UDP, "timeout_udp",
-	  &vs_timeout_table_dos.timeout[IP_VS_S_UDP],
-	  sizeof(int), 0644, NULL, &proc_dointvec_jiffies},
-	 {NET_IPV4_VS_TO_ICMP, "timeout_icmp",
-	  &vs_timeout_table_dos.timeout[IP_VS_S_ICMP],
-	  sizeof(int), 0644, NULL, &proc_dointvec_jiffies},
+	{
+		.ctl_name	= NET_IPV4_VS_TO_ES,
+		.procname	= "timeout_established",
+	  	.data	= &vs_timeout_table_dos.timeout[IP_VS_S_ESTABLISHED],
+		.maxlen		= sizeof(int),
+		.mode		= 0644, 
+		.proc_handler	= &proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	= NET_IPV4_VS_TO_SS,
+		.procname	= "timeout_synsent",
+		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_SYN_SENT],
+		.maxlen		= sizeof(int),
+		.mode		= 0644, 
+		.proc_handler	= &proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	= NET_IPV4_VS_TO_SR,
+		.procname	= "timeout_synrecv",
+		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_SYN_RECV],
+		.maxlen		= sizeof(int),
+		.mode		= 0644, 
+		.proc_handler	= &proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	= NET_IPV4_VS_TO_FW,
+		.procname	= "timeout_finwait",
+		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_FIN_WAIT],
+		.maxlen		= sizeof(int),
+		.mode		= 0644, 
+		.proc_handler	= &proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	= NET_IPV4_VS_TO_TW,
+		.procname	= "timeout_timewait",
+		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_TIME_WAIT],
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	= NET_IPV4_VS_TO_CL,
+		.procname	= "timeout_close",
+		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_CLOSE],
+		.maxlen		= sizeof(int),
+		.mode		= 0644, 
+		.proc_handler	= &proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	= NET_IPV4_VS_TO_CW,
+		.procname	= "timeout_closewait",
+		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_CLOSE_WAIT],
+		.maxlen		= sizeof(int),
+		.mode		= 0644, 
+		.proc_handler	= &proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	= NET_IPV4_VS_TO_LA,
+		.procname	= "timeout_lastack",
+		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_LAST_ACK],
+		.maxlen		= sizeof(int),
+		.mode		= 0644, 
+		.proc_handler	= &proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	= NET_IPV4_VS_TO_LI,
+		.procname	= "timeout_listen",
+		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_LISTEN],
+		.maxlen		= sizeof(int),
+		.mode		= 0644, 
+		.proc_handler	= &proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	= NET_IPV4_VS_TO_SA,
+		.procname	= "timeout_synack",
+		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_SYNACK],
+		.maxlen		= sizeof(int),
+		.mode		= 0644, 
+		.proc_handler	= &proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	= NET_IPV4_VS_TO_UDP,
+		.procname	= "timeout_udp",
+		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_UDP],
+		.maxlen		= sizeof(int),
+		.mode		= 0644, 
+		.proc_handler	= &proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	= NET_IPV4_VS_TO_ICMP,
+		.procname	= "timeout_icmp",
+		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_ICMP],
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_jiffies,
+	},
 #endif
-	 {NET_IPV4_VS_CACHE_BYPASS, "cache_bypass",
-	  &sysctl_ip_vs_cache_bypass, sizeof(int), 0644, NULL,
-	  &proc_dointvec},
-	 {NET_IPV4_VS_EXPIRE_NODEST_CONN, "expire_nodest_conn",
-	  &sysctl_ip_vs_expire_nodest_conn, sizeof(int), 0644, NULL,
-	  &proc_dointvec},
-	 {NET_IPV4_VS_SYNC_THRESHOLD, "sync_threshold",
-	  &sysctl_ip_vs_sync_threshold, sizeof(sysctl_ip_vs_sync_threshold),
-	  0644, NULL, &proc_do_sync_threshold},
-	 {NET_IPV4_VS_NAT_ICMP_SEND, "nat_icmp_send",
-	  &sysctl_ip_vs_nat_icmp_send, sizeof(int), 0644, NULL,
-	  &proc_dointvec},
-	 {0}},
-	{{NET_IPV4_VS, "vs", NULL, 0, 0555, ipv4_vs_table.vs_vars},
-	 {0}},
-	{{NET_IPV4, "ipv4", NULL, 0, 0555, ipv4_vs_table.vs_dir},
-	 {0}},
-	{{CTL_NET, "net", NULL, 0, 0555, ipv4_vs_table.ipv4_dir},
-	 {0}}
+	{
+		.ctl_name	= NET_IPV4_VS_CACHE_BYPASS,
+		.procname	= "cache_bypass",
+		.data		= &sysctl_ip_vs_cache_bypass,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+	{
+		.ctl_name	= NET_IPV4_VS_EXPIRE_NODEST_CONN,
+		.procname	= "expire_nodest_conn",
+		.data		= &sysctl_ip_vs_expire_nodest_conn,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+	{
+		.ctl_name	= NET_IPV4_VS_SYNC_THRESHOLD,
+		.procname	= "sync_threshold",
+		.data		= &sysctl_ip_vs_sync_threshold,
+		.maxlen		= sizeof(sysctl_ip_vs_sync_threshold),
+		.mode		= 0644,
+		.proc_handler	= &proc_do_sync_threshold,
+	},
+	{
+		.ctl_name	= NET_IPV4_VS_NAT_ICMP_SEND,
+		.procname	= "nat_icmp_send",
+		.data		= &sysctl_ip_vs_nat_icmp_send,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+	{ .ctl_name = 0 }
+};
+
+static ctl_table vs_table[] = {
+	{
+		.ctl_name	= NET_IPV4_VS,
+		.procname	= "vs",
+		.mode		= 0555,
+		.child		= vs_vars
+	},
+	{ .ctl_name = 0 }
+};
+
+static ctl_table ipv4_table[] = {
+	{
+		.ctl_name	= NET_IPV4,
+		.procname	= "ipv4",
+		.mode		= 0555,
+		.child		= vs_table,
+	},
+	{ .ctl_name = 0 }
 };
 
+static ctl_table vs_root_table[] = {
+	{
+		.ctl_name	= CTL_NET,
+		.procname	= "net",
+		.mode		= 0555,
+		.child		= ipv4_table,
+	},
+	{ .ctl_name = 0 }
+};
+
+static struct ctl_table_header * sysctl_header;
+
 #ifdef CONFIG_PROC_FS
 
 struct ip_vs_iter {
@@ -2184,9 +2312,13 @@
 
 
 static struct nf_sockopt_ops ip_vs_sockopts = {
-	{ NULL, NULL }, PF_INET,
-	IP_VS_BASE_CTL, IP_VS_SO_SET_MAX+1, do_ip_vs_set_ctl,
-	IP_VS_BASE_CTL, IP_VS_SO_GET_MAX+1, do_ip_vs_get_ctl
+	.pf		= PF_INET,
+	.set_optmin	= IP_VS_BASE_CTL,
+	.set_optmax	= IP_VS_SO_SET_MAX+1,
+	.set		= do_ip_vs_set_ctl,
+	.get_optmin	= IP_VS_BASE_CTL,
+	.get_optmax	= IP_VS_SO_GET_MAX+1,
+	.get		= do_ip_vs_get_ctl,
 };
 
 
@@ -2206,8 +2338,7 @@
 	proc_net_fops_create("ip_vs", 0, &ip_vs_info_fops);
 	proc_net_fops_create("ip_vs_stats",0, &ip_vs_stats_fops);
 
-	ipv4_vs_table.sysctl_header =
-		register_sysctl_table(ipv4_vs_table.root_dir, 0);
+	sysctl_header = register_sysctl_table(vs_root_table, 0);
 
 	/* Initialize ip_vs_svc_table, ip_vs_svc_fwm_table, ip_vs_rtable */
 	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++)  {
@@ -2239,7 +2370,7 @@
 	ip_vs_trash_cleanup();
 	del_timer_sync(&defense_timer);
 	ip_vs_kill_estimator(&ip_vs_stats);
-	unregister_sysctl_table(ipv4_vs_table.sysctl_header);
+	unregister_sysctl_table(sysctl_header);
 	proc_net_remove("ip_vs_stats");
 	proc_net_remove("ip_vs");
 	nf_unregister_sockopt(&ip_vs_sockopts);
-- 
Man once surrendering his reason, has no remaining guard against absurdities
the most monstrous, and like a ship without rudder, is the sport of every wind.

-Thomas Jefferson to James Smith, 1822
