From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 10/13] bridge: Add multicast_router sysfs entries
Date: Tue, 9 Mar 2010 20:25:26 +0800
Message-ID: <20100309122526.GA12403@gondor.apana.org.au>
References: <20100226153410.GA26419@gondor.apana.org.au> <E1Nl2Dj-0006wU-LU@gondolin.me.apana.org.au> <20100226164211.1a02a31b@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39807 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750715Ab0CIMZg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Mar 2010 07:25:36 -0500
Content-Disposition: inline
In-Reply-To: <20100226164211.1a02a31b@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 26, 2010 at 04:42:11PM -0800, Stephen Hemminger wrote:
> 
> I like the functionality, but don't like users whacking on sysfs
> directly. Could you send patches to integrate a user API into
> bridge-utils; the utils are at: 
>   git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/bridge-utils.git

Here it is:

commit 0eff6a003b34eec7f7216a8cd93cb545e25196b1
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Tue Mar 9 20:21:20 2010 +0800

    bridge-utils: Add IGMP snooping support
    
    This patch adds support for setting/reading IGMP snooping parameters.
    
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/brctl/brctl_cmd.c b/brctl/brctl_cmd.c
index d37e99c..50dea20 100644
--- a/brctl/brctl_cmd.c
+++ b/brctl/brctl_cmd.c
@@ -247,6 +247,209 @@ static int br_cmd_setmaxage(int argc, char *const* argv)
 	return err != 0;
 }
 
+static int br_cmd_sethashel(int argc, char *const* argv)
+{
+	int elasticity;
+	int err;
+
+	if (sscanf(argv[2], "%i", &elasticity) != 1) {
+		fprintf(stderr,"bad elasticity\n");
+		return 1;
+	}
+	err = br_set(argv[1], "hash_elasticity", elasticity, 0);
+	if (err)
+		fprintf(stderr, "set hash elasticity failed: %s\n",
+			strerror(err));
+
+	return err != 0;
+}
+
+static int br_cmd_sethashmax(int argc, char *const* argv)
+{
+	int max;
+	int err;
+
+	if (sscanf(argv[2], "%i", &max) != 1) {
+		fprintf(stderr,"bad max\n");
+		return 1;
+	}
+	err = br_set(argv[1], "hash_max", max, 0);
+	if (err)
+		fprintf(stderr, "set hash max failed: %s\n", strerror(err));
+
+	return err != 0;
+}
+
+static int br_cmd_setmclmc(int argc, char *const* argv)
+{
+	int lmc;
+	int err;
+
+	if (sscanf(argv[2], "%i", &lmc) != 1) {
+		fprintf(stderr,"bad count\n");
+		return 1;
+	}
+	err = br_set(argv[1], "multicast_last_member_count", lmc, 0);
+	if (err)
+		fprintf(stderr, "set multicast last member count failed: %s\n",
+			strerror(err));
+
+	return err != 0;
+}
+
+static int br_cmd_setmcrouter(int argc, char *const* argv)
+{
+	int router;
+	int err;
+
+	if (sscanf(argv[2], "%i", &router) != 1) {
+		fprintf(stderr,"bad router\n");
+		return 1;
+	}
+	err = br_set(argv[1], "multicast_router", router, 0);
+	if (err)
+		fprintf(stderr, "set multicast router failed: %s\n",
+			strerror(err));
+
+	return err != 0;
+}
+
+static int br_cmd_setmcsnoop(int argc, char *const* argv)
+{
+	int snoop;
+	int err;
+
+	if (sscanf(argv[2], "%i", &snoop) != 1) {
+		fprintf(stderr,"bad snooping\n");
+		return 1;
+	}
+	err = br_set(argv[1], "multicast_snooping", snoop, 0);
+	if (err)
+		fprintf(stderr, "set multicast snooping failed: %s\n",
+			strerror(err));
+
+	return err != 0;
+}
+
+static int br_cmd_setmcsqc(int argc, char *const* argv)
+{
+	int sqc;
+	int err;
+
+	if (sscanf(argv[2], "%i", &sqc) != 1) {
+		fprintf(stderr,"bad count\n");
+		return 1;
+	}
+	err = br_set(argv[1], "multicast_startup_query_count", sqc, 0);
+	if (err)
+		fprintf(stderr, "set multicast startup query count failed: "
+				"%s\n", strerror(err));
+
+	return err != 0;
+}
+
+static int br_cmd_setmclmi(int argc, char *const* argv)
+{
+	struct timeval tv;
+	int err;
+
+	if (strtotimeval(&tv, argv[2])) {
+		fprintf(stderr, "bad interval\n");
+		return 1;
+	}
+	err = br_set_time(argv[1], "multicast_last_member_interval", &tv);
+	if (err)
+		fprintf(stderr, "set multicast last member interval failed: "
+				"%s\n", strerror(err));
+
+	return err != 0;
+}
+
+static int br_cmd_setmcmi(int argc, char *const* argv)
+{
+	struct timeval tv;
+	int err;
+
+	if (strtotimeval(&tv, argv[2])) {
+		fprintf(stderr, "bad interval\n");
+		return 1;
+	}
+	err = br_set_time(argv[1], "multicast_membership_interval", &tv);
+	if (err)
+		fprintf(stderr, "set multicast membership interval failed: "
+				"%s\n", strerror(err));
+
+	return err != 0;
+}
+
+static int br_cmd_setmcqpi(int argc, char *const* argv)
+{
+	struct timeval tv;
+	int err;
+
+	if (strtotimeval(&tv, argv[2])) {
+		fprintf(stderr, "bad interval\n");
+		return 1;
+	}
+	err = br_set_time(argv[1], "multicast_querier_interval", &tv);
+	if (err)
+		fprintf(stderr, "set multicast querier interval failed: %s\n",
+			strerror(err));
+
+	return err != 0;
+}
+
+static int br_cmd_setmcqi(int argc, char *const* argv)
+{
+	struct timeval tv;
+	int err;
+
+	if (strtotimeval(&tv, argv[2])) {
+		fprintf(stderr, "bad interval\n");
+		return 1;
+	}
+	err = br_set_time(argv[1], "multicast_query_interval", &tv);
+	if (err)
+		fprintf(stderr, "set multicast query interval failed: %s\n",
+			strerror(err));
+
+	return err != 0;
+}
+
+static int br_cmd_setmcqri(int argc, char *const* argv)
+{
+	struct timeval tv;
+	int err;
+
+	if (strtotimeval(&tv, argv[2])) {
+		fprintf(stderr, "bad interval\n");
+		return 1;
+	}
+	err = br_set_time(argv[1], "multicast_query_response_interval", &tv);
+	if (err)
+		fprintf(stderr, "set multicast query response interval "
+				"failed: %s\n", strerror(err));
+
+	return err != 0;
+}
+
+static int br_cmd_setmcsqi(int argc, char *const* argv)
+{
+	struct timeval tv;
+	int err;
+
+	if (strtotimeval(&tv, argv[2])) {
+		fprintf(stderr, "bad interval\n");
+		return 1;
+	}
+	err = br_set_time(argv[1], "multicast_startup_query_interval", &tv);
+	if (err)
+		fprintf(stderr, "set multicast startup query interval "
+				"failed: %s\n", strerror(err));
+
+	return err != 0;
+}
+
 static int br_cmd_setpathcost(int argc, char *const* argv)
 {
 	int cost, err;
@@ -280,6 +483,24 @@ static int br_cmd_setportprio(int argc, char *const* argv)
 	return err != 0;
 }
 
+static int br_cmd_setportmcrouter(int argc, char *const* argv)
+{
+	int router;
+	int err;
+
+	if (sscanf(argv[3], "%i", &router) != 1) {
+		fprintf(stderr, "bad router\n");
+		return 1;
+	}
+
+	err = br_set_port_mcrouter(argv[1], argv[2], router);
+	if (err)
+		fprintf(stderr, "set port multicast router failed: %s\n",
+			strerror(errno));
+
+	return err != 0;
+}
+
 static int br_cmd_stp(int argc, char *const* argv)
 {
 	int stp, err;
@@ -450,10 +671,36 @@ static const struct command commands[] = {
 	  "<bridge> <time>\t\tset hello time" },
 	{ 2, "setmaxage", br_cmd_setmaxage,
 	  "<bridge> <time>\t\tset max message age" },
+	{ 2, "sethashel", br_cmd_sethashel,
+	  "<bridge> <int>\t\tset hash elasticity" },
+	{ 2, "sethashmax", br_cmd_sethashmax,
+	  "<bridge> <int>\t\tset hash max" },
+	{ 2, "setmclmc", br_cmd_setmclmc,
+	  "<bridge> <int>\t\tset multicast last member count" },
+	{ 2, "setmcrouter", br_cmd_setmcrouter,
+	  "<bridge> <int>\t\tset multicast router" },
+	{ 2, "setmcsnoop", br_cmd_setmcsnoop,
+	  "<bridge> <int>\t\tset multicast snooping" },
+	{ 2, "setmcsqc", br_cmd_setmcsqc,
+	  "<bridge> <int>\t\tset multicast startup query count" },
+	{ 2, "setmclmi", br_cmd_setmclmi,
+	  "<bridge> <time>\t\tset multicast last member interval" },
+	{ 2, "setmcmi", br_cmd_setmcmi,
+	  "<bridge> <time>\t\tset multicast membership interval" },
+	{ 2, "setmcqpi", br_cmd_setmcqpi,
+	  "<bridge> <time>\t\tset multicast querier interval" },
+	{ 2, "setmcqi", br_cmd_setmcqi,
+	  "<bridge> <time>\t\tset multicast query interval" },
+	{ 2, "setmcqri", br_cmd_setmcqri,
+	  "<bridge> <time>\t\tset multicast query response interval" },
+	{ 2, "setmcqri", br_cmd_setmcsqi,
+	  "<bridge> <time>\t\tset multicast startup query interval" },
 	{ 3, "setpathcost", br_cmd_setpathcost, 
 	  "<bridge> <port> <cost>\tset path cost" },
 	{ 3, "setportprio", br_cmd_setportprio,
 	  "<bridge> <port> <prio>\tset port priority" },
+	{ 3, "setportmcrouter", br_cmd_setportmcrouter,
+	  "<bridge> <port> <int>\tset port multicast router" },
 	{ 0, "show", br_cmd_show, "\t\t\tshow a list of bridges" },
 	{ 1, "showmacs", br_cmd_showmacs, 
 	  "<bridge>\t\tshow a list of mac addrs"},
diff --git a/brctl/brctl_disp.c b/brctl/brctl_disp.c
index 3e81241..0cf64b8 100644
--- a/brctl/brctl_disp.c
+++ b/brctl/brctl_disp.c
@@ -88,6 +88,7 @@ static int dump_port_info(const char *br, const char *p,  void *arg)
 	printf("\n designated cost\t%4i", pinfo.designated_cost);
 	printf("\t\t\thold timer\t\t");
 	br_show_timer(&pinfo.hold_timer_value);
+	printf("\n mc router\t\t%4i", pinfo.multicast_router);
 	printf("\n flags\t\t\t");
 	if (pinfo.config_pending)
 		printf("CONFIG_PENDING ");
@@ -133,6 +134,26 @@ void br_dump_info(const char *br, const struct bridge_info *bri)
 	br_show_timer(&bri->topology_change_timer_value);
 	printf("\t\t\tgc timer\t\t");
 	br_show_timer(&bri->gc_timer_value);
+	printf("\n hash elasticity\t%4i", bri->hash_elasticity);
+	printf("\t\t\thash max\t\t%4i", bri->hash_max);
+	printf("\n mc last member count\t%4i",
+	       bri->multicast_last_member_count);
+	printf("\t\t\tmc init query count\t%4i",
+	       bri->multicast_startup_query_count);
+	printf("\n mc router\t\t%4i", bri->multicast_router);
+	printf("\t\t\tmc snooping\t\t%4i", bri->multicast_snooping);
+	printf("\n mc last member timer\t");
+	br_show_timer(&bri->multicast_last_member_interval);
+	printf("\t\t\tmc membership timer\t");
+	br_show_timer(&bri->multicast_membership_interval);
+	printf("\n mc querier timer\t");
+	br_show_timer(&bri->multicast_querier_interval);
+	printf("\t\t\tmc query interval\t");
+	br_show_timer(&bri->multicast_query_interval);
+	printf("\n mc response interval\t");
+	br_show_timer(&bri->multicast_query_response_interval);
+	printf("\t\t\tmc init query interval\t");
+	br_show_timer(&bri->multicast_startup_query_interval);
 	printf("\n flags\t\t\t");
 	if (bri->topology_change)
 		printf("TOPOLOGY_CHANGE ");
diff --git a/libbridge/libbridge.h b/libbridge/libbridge.h
index 39964f2..ae33ffd 100644
--- a/libbridge/libbridge.h
+++ b/libbridge/libbridge.h
@@ -39,6 +39,10 @@ struct bridge_info
 	struct bridge_id designated_root;
 	struct bridge_id bridge_id;
 	unsigned root_path_cost;
+	unsigned hash_elasticity;
+	unsigned hash_max;
+	unsigned multicast_last_member_count;
+	unsigned multicast_startup_query_count;
 	struct timeval max_age;
 	struct timeval hello_time;
 	struct timeval forward_delay;
@@ -49,11 +53,19 @@ struct bridge_info
 	unsigned char stp_enabled;
 	unsigned char topology_change;
 	unsigned char topology_change_detected;
+	unsigned char multicast_router;
+	unsigned char multicast_snooping;
 	struct timeval ageing_time;
 	struct timeval hello_timer_value;
 	struct timeval tcn_timer_value;
 	struct timeval topology_change_timer_value;
 	struct timeval gc_timer_value;
+	struct timeval multicast_last_member_interval;
+	struct timeval multicast_membership_interval;
+	struct timeval multicast_querier_interval;
+	struct timeval multicast_query_interval;
+	struct timeval multicast_query_response_interval;
+	struct timeval multicast_startup_query_interval;
 };
 
 struct fdb_entry
@@ -75,6 +87,7 @@ struct port_info
 	unsigned char top_change_ack;
 	unsigned char config_pending;
 	unsigned char state;
+	unsigned char multicast_router;
 	unsigned path_cost;
 	unsigned designated_cost;
 	struct timeval message_age_timer_value;
@@ -102,6 +115,9 @@ extern int br_add_bridge(const char *brname);
 extern int br_del_bridge(const char *brname);
 extern int br_add_interface(const char *br, const char *dev);
 extern int br_del_interface(const char *br, const char *dev);
+extern int br_set(const char *bridge, const char *name,
+		  unsigned long value, unsigned long oldcode);
+extern int br_set_time(const char *br, const char *name, struct timeval *tv);
 extern int br_set_bridge_forward_delay(const char *br, struct timeval *tv);
 extern int br_set_bridge_hello_time(const char *br, struct timeval *tv);
 extern int br_set_bridge_max_age(const char *br, struct timeval *tv);
@@ -110,6 +126,8 @@ extern int br_set_stp_state(const char *br, int stp_state);
 extern int br_set_bridge_priority(const char *br, int bridge_priority);
 extern int br_set_port_priority(const char *br, const char *p, 
 				int port_priority);
+extern int br_set_port_mcrouter(const char *bridge, const char *port,
+				int value);
 extern int br_set_path_cost(const char *br, const char *p, 
 			    int path_cost);
 extern int br_read_fdb(const char *br, struct fdb_entry *fdbs, 
diff --git a/libbridge/libbridge_devif.c b/libbridge/libbridge_devif.c
index aa8bc36..180c2f9 100644
--- a/libbridge/libbridge_devif.c
+++ b/libbridge/libbridge_devif.c
@@ -189,6 +189,28 @@ int br_get_bridge_info(const char *bridge, struct bridge_info *info)
 	info->topology_change = fetch_int(path, "topology_change");
 	info->topology_change_detected = fetch_int(path, "topology_change_detected");
 
+	info->hash_elasticity = fetch_int(path, "hash_elasticity");
+	info->hash_max = fetch_int(path, "hash_max");
+	info->multicast_last_member_count =
+		fetch_int(path, "multicast_last_member_count");
+	info->multicast_router = fetch_int(path, "multicast_router");
+	info->multicast_snooping = fetch_int(path, "multicast_snooping");
+	info->multicast_startup_query_count =
+		fetch_int(path, "multicast_startup_query_count");
+
+	fetch_tv(path, "multicast_last_member_interval",
+		 &info->multicast_last_member_interval);
+	fetch_tv(path, "multicast_membership_interval",
+		 &info->multicast_membership_interval);
+	fetch_tv(path, "multicast_querier_interval",
+		 &info->multicast_querier_interval);
+	fetch_tv(path, "multicast_query_interval",
+		 &info->multicast_query_interval);
+	fetch_tv(path, "multicast_query_response_interval",
+		 &info->multicast_query_response_interval);
+	fetch_tv(path, "multicast_startup_query_interval",
+		 &info->multicast_startup_query_interval);
+
 	closedir(dir);
 	return 0;
 
@@ -272,6 +294,7 @@ int br_get_port_info(const char *brname, const char *port,
 	fetch_tv(path, "forward_delay_timer", &info->forward_delay_timer_value);
 	fetch_tv(path, "hold_timer", &info->hold_timer_value);
 	info->hairpin_mode = fetch_int(path, "hairpin_mode");
+	info->multicast_router = fetch_int(path, "multicast_router");
 
 	closedir(d);
 
@@ -281,8 +304,8 @@ fallback:
 }
 
 
-static int br_set(const char *bridge, const char *name,
-		  unsigned long value, unsigned long oldcode)
+int br_set(const char *bridge, const char *name,
+	   unsigned long value, unsigned long oldcode)
 {
 	int ret;
 	char path[SYSFS_PATH_MAX];
@@ -294,7 +317,7 @@ static int br_set(const char *bridge, const char *name,
 	if (f) {
 		ret = fprintf(f, "%ld\n", value);
 		fclose(f);
-	} else {
+	} else if (oldcode) {
 		/* fallback to old ioctl */
 		struct ifreq ifr;
 		unsigned long args[4] = { oldcode, value, 0, 0 };
@@ -302,11 +325,17 @@ static int br_set(const char *bridge, const char *name,
 		strncpy(ifr.ifr_name, bridge, IFNAMSIZ);
 		ifr.ifr_data = (char *) &args;
 		ret = ioctl(br_socket_fd, SIOCDEVPRIVATE, &ifr);
-	}
+	} else
+		return ENOSYS;
 
 	return ret < 0 ? errno : 0;
 }
 
+int br_set_time(const char *br, const char *name, struct timeval *tv)
+{
+	return br_set(br, name, __tv_to_jiffies(tv), 0);
+}
+
 int br_set_bridge_forward_delay(const char *br, struct timeval *tv)
 {
 	return br_set(br, "forward_delay", __tv_to_jiffies(tv),
@@ -355,7 +384,7 @@ static int port_set(const char *bridge, const char *ifname,
 	if (f) {
 		ret = fprintf(f, "%ld\n", value);
 		fclose(f);
-	} else {
+	} else if (oldcode) {
 		int index = get_portno(bridge, ifname);
 
 		if (index < 0)
@@ -368,7 +397,8 @@ static int port_set(const char *bridge, const char *ifname,
 			ifr.ifr_data = (char *) &args;
 			ret = ioctl(br_socket_fd, SIOCDEVPRIVATE, &ifr);
 		}
-	}
+	} else
+		return ENOSYS;
 
 	return ret < 0 ? errno : 0;
 }
@@ -378,6 +408,11 @@ int br_set_port_priority(const char *bridge, const char *port, int priority)
 	return port_set(bridge, port, "priority", priority, BRCTL_SET_PORT_PRIORITY);
 }
 
+int br_set_port_mcrouter(const char *bridge, const char *port, int value)
+{
+	return port_set(bridge, port, "multicast_router", value, 0);
+}
+
 int br_set_path_cost(const char *bridge, const char *port, int cost)
 {
 	return port_set(bridge, port, "path_cost", cost, BRCTL_SET_PATH_COST);

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
