From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Subject: [PATCH v3 07/10] ss: renaming and export of current_filter
Date: Thu, 20 Aug 2015 22:40:18 +0200
Message-ID: <1440103221-21854-8-git-send-email-matthias.tafelmeier@gmx.net>
References: <1440103221-21854-1-git-send-email-matthias.tafelmeier@gmx.net>
Cc: hagen@jauu.net, shemminger@osdl.org, fw@strlen.de,
	edumazet@google.com, daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.22]:50555 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752777AbbHTUkr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Aug 2015 16:40:47 -0400
In-Reply-To: <1440103221-21854-1-git-send-email-matthias.tafelmeier@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Exported current_filter as ss_current_filter, because in
the fmt handlers, I need that piece of info to resolve out issues of json.

Signed-off-by: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>

Conflicts:
	misc/ss.c
---
 misc/ss.c | 220 +++++++++++++++++++++++++++++++-------------------------------
 1 file changed, 110 insertions(+), 110 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 2fbdd7f..c00954d 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -199,7 +199,7 @@ static const struct filter default_afs[AF_MAX] = {
 };
 
 static int do_default = 1;
-static struct filter current_filter;
+struct filter ss_current_filter;
 
 static void filter_db_set(struct filter *f, int db)
 {
@@ -1191,7 +1191,7 @@ void *parse_hostcond(char *addr, bool is_port)
 	struct aafilter a = { .port = -1 };
 	struct aafilter *res;
 	int fam = preferred_family;
-	struct filter *f = &current_filter;
+	struct filter *f = &ss_current_filter;
 
 	if (fam == AF_UNIX || strncmp(addr, "unix:", 5) == 0) {
 		char *p;
@@ -1290,9 +1290,9 @@ void *parse_hostcond(char *addr, bool is_port)
 			if (get_integer(&a.port, port, 0)) {
 				struct servent *se1 = NULL;
 				struct servent *se2 = NULL;
-				if (current_filter.dbs&(1<<UDP_DB))
+				if (ss_current_filter.dbs & (1 << UDP_DB))
 					se1 = getservbyname(port, UDP_PROTO);
-				if (current_filter.dbs&(1<<TCP_DB))
+				if (ss_current_filter.dbs & (1 << TCP_DB))
 					se2 = getservbyname(port, TCP_PROTO);
 				if (se1 && se2 && se1->s_port != se2->s_port) {
 					fprintf(stderr, "Error: ambiguous port \"%s\".\n", port);
@@ -1306,9 +1306,9 @@ void *parse_hostcond(char *addr, bool is_port)
 					struct scache *s;
 					for (s = rlist; s; s = s->next) {
 						if ((s->proto == UDP_PROTO &&
-						     (current_filter.dbs&(1<<UDP_DB))) ||
+						     (ss_current_filter.dbs&(1<<UDP_DB))) ||
 						    (s->proto == TCP_PROTO &&
-						     (current_filter.dbs&(1<<TCP_DB)))) {
+						     (ss_current_filter.dbs&(1<<TCP_DB)))) {
 							if (s->name && strcmp(s->name, port) == 0) {
 								if (a.port > 0 && a.port != s->port) {
 									fprintf(stderr, "Error: ambiguous port \"%s\".\n", port);
@@ -3226,19 +3226,19 @@ int main(int argc, char *argv[])
 			follow_events = 1;
 			break;
 		case 'd':
-			filter_db_set(&current_filter, DCCP_DB);
+			filter_db_set(&ss_current_filter, DCCP_DB);
 			break;
 		case 't':
-			filter_db_set(&current_filter, TCP_DB);
+			filter_db_set(&ss_current_filter, TCP_DB);
 			break;
 		case 'u':
-			filter_db_set(&current_filter, UDP_DB);
+			filter_db_set(&ss_current_filter, UDP_DB);
 			break;
 		case 'w':
-			filter_db_set(&current_filter, RAW_DB);
+			filter_db_set(&ss_current_filter, RAW_DB);
 			break;
 		case 'x':
-			filter_af_set(&current_filter, AF_UNIX);
+			filter_af_set(&ss_current_filter, AF_UNIX);
 			break;
 		case 'a':
 			state_filter = SS_ALL;
@@ -3247,25 +3247,25 @@ int main(int argc, char *argv[])
 			state_filter = (1 << SS_LISTEN) | (1 << SS_CLOSE);
 			break;
 		case '4':
-			filter_af_set(&current_filter, AF_INET);
+			filter_af_set(&ss_current_filter, AF_INET);
 			break;
 		case '6':
-			filter_af_set(&current_filter, AF_INET6);
+			filter_af_set(&ss_current_filter, AF_INET6);
 			break;
 		case '0':
-			filter_af_set(&current_filter, AF_PACKET);
+			filter_af_set(&ss_current_filter, AF_PACKET);
 			break;
 		case 'f':
 			if (strcmp(optarg, "inet") == 0)
-				filter_af_set(&current_filter, AF_INET);
+				filter_af_set(&ss_current_filter, AF_INET);
 			else if (strcmp(optarg, "inet6") == 0)
-				filter_af_set(&current_filter, AF_INET6);
+				filter_af_set(&ss_current_filter, AF_INET6);
 			else if (strcmp(optarg, "link") == 0)
-				filter_af_set(&current_filter, AF_PACKET);
+				filter_af_set(&ss_current_filter, AF_PACKET);
 			else if (strcmp(optarg, "unix") == 0)
-				filter_af_set(&current_filter, AF_UNIX);
+				filter_af_set(&ss_current_filter, AF_UNIX);
 			else if (strcmp(optarg, "netlink") == 0)
-				filter_af_set(&current_filter, AF_NETLINK);
+				filter_af_set(&ss_current_filter, AF_NETLINK);
 			else if (strcmp(optarg, "help") == 0)
 				help();
 			else {
@@ -3278,9 +3278,9 @@ int main(int argc, char *argv[])
 		{
 			char *p, *p1;
 			if (!saw_query) {
-				current_filter.dbs = 0;
+				ss_current_filter.dbs = 0;
 				state_filter = state_filter ?
-				               state_filter : SS_CONN;
+							state_filter : SS_CONN;
 				saw_query = 1;
 				do_default = 0;
 			}
@@ -3289,44 +3289,44 @@ int main(int argc, char *argv[])
 				if ((p1 = strchr(p, ',')) != NULL)
 					*p1 = 0;
 				if (strcmp(p, "all") == 0) {
-					filter_default_dbs(&current_filter);
+					filter_default_dbs(&ss_current_filter);
 				} else if (strcmp(p, "inet") == 0) {
-					filter_db_set(&current_filter, UDP_DB);
-					filter_db_set(&current_filter, DCCP_DB);
-					filter_db_set(&current_filter, TCP_DB);
-					filter_db_set(&current_filter, RAW_DB);
+					filter_db_set(&ss_current_filter, UDP_DB);
+					filter_db_set(&ss_current_filter, DCCP_DB);
+					filter_db_set(&ss_current_filter, TCP_DB);
+					filter_db_set(&ss_current_filter, RAW_DB);
 				} else if (strcmp(p, "udp") == 0) {
-					filter_db_set(&current_filter, UDP_DB);
+					filter_db_set(&ss_current_filter, UDP_DB);
 				} else if (strcmp(p, "dccp") == 0) {
-					filter_db_set(&current_filter, DCCP_DB);
+					filter_db_set(&ss_current_filter, DCCP_DB);
 				} else if (strcmp(p, "tcp") == 0) {
-					filter_db_set(&current_filter, TCP_DB);
+					filter_db_set(&ss_current_filter, TCP_DB);
 				} else if (strcmp(p, "raw") == 0) {
-					filter_db_set(&current_filter, RAW_DB);
+					filter_db_set(&ss_current_filter, RAW_DB);
 				} else if (strcmp(p, "unix") == 0) {
-					filter_db_set(&current_filter, UNIX_ST_DB);
-					filter_db_set(&current_filter, UNIX_DG_DB);
-					filter_db_set(&current_filter, UNIX_SQ_DB);
+					filter_db_set(&ss_current_filter, UNIX_ST_DB);
+					filter_db_set(&ss_current_filter, UNIX_DG_DB);
+					filter_db_set(&ss_current_filter, UNIX_SQ_DB);
 				} else if (strcasecmp(p, "unix_stream") == 0 ||
 					   strcmp(p, "u_str") == 0) {
-					filter_db_set(&current_filter, UNIX_ST_DB);
+					filter_db_set(&ss_current_filter, UNIX_ST_DB);
 				} else if (strcasecmp(p, "unix_dgram") == 0 ||
 					   strcmp(p, "u_dgr") == 0) {
-					filter_db_set(&current_filter, UNIX_DG_DB);
+					filter_db_set(&ss_current_filter, UNIX_DG_DB);
 				} else if (strcasecmp(p, "unix_seqpacket") == 0 ||
 					   strcmp(p, "u_seq") == 0) {
-					filter_db_set(&current_filter, UNIX_SQ_DB);
+					filter_db_set(&ss_current_filter, UNIX_SQ_DB);
 				} else if (strcmp(p, "packet") == 0) {
-					filter_db_set(&current_filter, PACKET_R_DB);
-					filter_db_set(&current_filter, PACKET_DG_DB);
+					filter_db_set(&ss_current_filter, PACKET_R_DB);
+					filter_db_set(&ss_current_filter, PACKET_DG_DB);
 				} else if (strcmp(p, "packet_raw") == 0 ||
 					   strcmp(p, "p_raw") == 0) {
-					filter_db_set(&current_filter, PACKET_R_DB);
+					filter_db_set(&ss_current_filter, PACKET_R_DB);
 				} else if (strcmp(p, "packet_dgram") == 0 ||
 					   strcmp(p, "p_dgr") == 0) {
-					filter_db_set(&current_filter, PACKET_DG_DB);
+					filter_db_set(&ss_current_filter, PACKET_DG_DB);
 				} else if (strcmp(p, "netlink") == 0) {
-					filter_db_set(&current_filter, NETLINK_DB);
+					filter_db_set(&ss_current_filter, NETLINK_DB);
 				} else {
 					fprintf(stderr, "ss: \"%s\" is illegal socket table id\n", p);
 					usage();
@@ -3395,7 +3395,7 @@ int main(int argc, char *argv[])
 
 	/* Now parse filter... */
 	if (argc == 0 && filter_fp) {
-		if (ssfilter_parse(&current_filter.f, 0, NULL, filter_fp))
+		if (ssfilter_parse(&ss_current_filter.f, 0, NULL, filter_fp))
 			usage();
 	}
 
@@ -3421,32 +3421,32 @@ int main(int argc, char *argv[])
 
 	if (do_default) {
 		state_filter = state_filter ? state_filter : SS_CONN;
-		filter_default_dbs(&current_filter);
+		filter_default_dbs(&ss_current_filter);
 	}
 
-	filter_states_set(&current_filter, state_filter);
-	filter_merge_defaults(&current_filter);
+	filter_states_set(&ss_current_filter, state_filter);
+	filter_merge_defaults(&ss_current_filter);
 
 	if (resolve_services && resolve_hosts &&
-	    (current_filter.dbs&(UNIX_DBM|(1<<TCP_DB)|(1<<UDP_DB)|(1<<DCCP_DB))))
+	    (ss_current_filter.dbs&(UNIX_DBM|(1<<TCP_DB)|(1<<UDP_DB)|(1<<DCCP_DB))))
 		init_service_resolver();
 
-	if (current_filter.dbs == 0) {
+	if (ss_current_filter.dbs == 0) {
 		fprintf(stderr, "ss: no socket tables to show with such filter.\n");
 		exit(0);
 	}
-	if (current_filter.families == 0) {
+	if (ss_current_filter.families == 0) {
 		fprintf(stderr, "ss: no families to show with such filter.\n");
 		exit(0);
 	}
-	if (current_filter.states == 0) {
+	if (ss_current_filter.states == 0) {
 		fprintf(stderr, "ss: no socket states to show with such filter.\n");
 		exit(0);
 	}
 
 	if (dump_tcpdiag) {
 		FILE *dump_fp = stdout;
-		if (!(current_filter.dbs & (1<<TCP_DB))) {
+		if (!(ss_current_filter.dbs & (1<<TCP_DB))) {
 			fprintf(stderr, "ss: tcpdiag dump requested and no tcp in filter.\n");
 			exit(0);
 		}
@@ -3458,25 +3458,25 @@ int main(int argc, char *argv[])
 			}
 		}
 		printf("\"TCP\": [\n");
-		inet_show_netlink(&current_filter, dump_fp, IPPROTO_TCP);
-		res_json_fmt_branch(current_filter.dbs & (1<<NETLINK_DB) ||
-				current_filter.dbs & PACKET_DBM ||
-				current_filter.dbs & UNIX_DBM ||
-				current_filter.dbs & (1<<RAW_DB) ||
-				current_filter.dbs & (1<<UDP_DB) ||
-				current_filter.dbs & (1<<TCP_DB) ||
-				current_filter.dbs & (1<<DCCP_DB), ']');
+		inet_show_netlink(&ss_current_filter, dump_fp, IPPROTO_TCP);
+		res_json_fmt_branch(ss_current_filter.dbs & (1<<NETLINK_DB) ||
+				ss_current_filter.dbs & PACKET_DBM ||
+				ss_current_filter.dbs & UNIX_DBM ||
+				ss_current_filter.dbs & (1<<RAW_DB) ||
+				ss_current_filter.dbs & (1<<UDP_DB) ||
+				ss_current_filter.dbs & (1<<TCP_DB) ||
+				ss_current_filter.dbs & (1<<DCCP_DB), ']');
 		fflush(dump_fp);
 		exit(0);
 	}
 
 	if (do_summary) {
-		print_summary(current_filter.dbs & PACKET_DBM ||
-				current_filter.dbs & UNIX_DBM ||
-				current_filter.dbs & (1<<RAW_DB) ||
-				current_filter.dbs & (1<<UDP_DB) ||
-				current_filter.dbs & (1<<TCP_DB) ||
-				current_filter.dbs & (1<<DCCP_DB));
+		print_summary(ss_current_filter.dbs & PACKET_DBM ||
+				ss_current_filter.dbs & UNIX_DBM ||
+				ss_current_filter.dbs & (1<<RAW_DB) ||
+				ss_current_filter.dbs & (1<<UDP_DB) ||
+				ss_current_filter.dbs & (1<<TCP_DB) ||
+				ss_current_filter.dbs & (1<<DCCP_DB));
 		if (do_default && argc == 0) {
 			if (json_output)
 				printf("}\n");
@@ -3484,15 +3484,15 @@ int main(int argc, char *argv[])
 		}
 	}
 
-	if (ssfilter_parse(&current_filter.f, argc, argv, filter_fp))
+	if (ssfilter_parse(&ss_current_filter.f, argc, argv, filter_fp))
 		usage();
 
 	netid_width = 0;
-	if (current_filter.dbs&(current_filter.dbs-1))
+	if (ss_current_filter.dbs & (ss_current_filter.dbs - 1))
 		netid_width = 5;
 
 	state_width = 0;
-	if (current_filter.states&(current_filter.states-1))
+	if (ss_current_filter.states & (ss_current_filter.states - 1))
 		state_width = 10;
 
 	screen_width = 80;
@@ -3545,90 +3545,90 @@ int main(int argc, char *argv[])
 
 	fflush(stdout);
 
-	if (current_filter.dbs & (1<<NETLINK_DB)) {
+	if (ss_current_filter.dbs & (1<<NETLINK_DB)) {
 		if (json_output) {
 			printf("\"NETLINK\": [\n");
-			netlink_show(&current_filter);
+			netlink_show(&ss_current_filter);
 			json_first_elem = 1;
-			res_json_fmt_branch(current_filter.dbs & PACKET_DBM ||
-					current_filter.dbs & UNIX_DBM ||
-					current_filter.dbs & (1<<RAW_DB) ||
-					current_filter.dbs & (1<<UDP_DB) ||
-					current_filter.dbs & (1<<TCP_DB) ||
-					current_filter.dbs & (1<<DCCP_DB), ']');
+			res_json_fmt_branch(ss_current_filter.dbs & PACKET_DBM ||
+					ss_current_filter.dbs & UNIX_DBM ||
+					ss_current_filter.dbs & (1<<RAW_DB) ||
+					ss_current_filter.dbs & (1<<UDP_DB) ||
+					ss_current_filter.dbs & (1<<TCP_DB) ||
+					ss_current_filter.dbs & (1<<DCCP_DB), ']');
 		} else
-			netlink_show(&current_filter);
+			netlink_show(&ss_current_filter);
 	}
-	if (current_filter.dbs & PACKET_DBM) {
+	if (ss_current_filter.dbs & PACKET_DBM) {
 		if (json_output) {
 			printf("\"PACKET\": [\n");
-			packet_show(&current_filter);
+			packet_show(&ss_current_filter);
 			json_first_elem = 1;
 			res_json_fmt_branch(
-					current_filter.dbs & UNIX_DBM ||
-					current_filter.dbs & (1<<RAW_DB) ||
-					current_filter.dbs & (1<<UDP_DB) ||
-					current_filter.dbs & (1<<TCP_DB) ||
-					current_filter.dbs & (1<<DCCP_DB), ']');
+					ss_current_filter.dbs & UNIX_DBM ||
+					ss_current_filter.dbs & (1<<RAW_DB) ||
+					ss_current_filter.dbs & (1<<UDP_DB) ||
+					ss_current_filter.dbs & (1<<TCP_DB) ||
+					ss_current_filter.dbs & (1<<DCCP_DB), ']');
 		} else
-			packet_show(&current_filter);
+			packet_show(&ss_current_filter);
 	}
-	if (current_filter.dbs & UNIX_DBM) {
+	if (ss_current_filter.dbs & UNIX_DBM) {
 		if (json_output) {
 			printf("\"UNIX\": [\n");
-			unix_show(&current_filter);
+			unix_show(&ss_current_filter);
 			json_first_elem = 1;
 			res_json_fmt_branch(
-					current_filter.dbs & (1<<RAW_DB) ||
-					current_filter.dbs & (1<<UDP_DB) ||
-					current_filter.dbs & (1<<TCP_DB) ||
-					current_filter.dbs & (1<<DCCP_DB), ']');
+					ss_current_filter.dbs & (1<<RAW_DB) ||
+					ss_current_filter.dbs & (1<<UDP_DB) ||
+					ss_current_filter.dbs & (1<<TCP_DB) ||
+					ss_current_filter.dbs & (1<<DCCP_DB), ']');
 
 		} else
-			unix_show(&current_filter);
+			unix_show(&ss_current_filter);
 	}
-	if (current_filter.dbs & (1<<RAW_DB)) {
+	if (ss_current_filter.dbs & (1<<RAW_DB)) {
 		if (json_output) {
 			printf("\"RAW\": [\n");
-			raw_show(&current_filter);
+			raw_show(&ss_current_filter);
 			json_first_elem = 1;
 			res_json_fmt_branch(
-					current_filter.dbs & (1<<UDP_DB) ||
-					current_filter.dbs & (1<<TCP_DB) ||
-					current_filter.dbs & (1<<DCCP_DB), ']');
+					ss_current_filter.dbs & (1<<UDP_DB) ||
+					ss_current_filter.dbs & (1<<TCP_DB) ||
+					ss_current_filter.dbs & (1<<DCCP_DB), ']');
 
 		} else
-			raw_show(&current_filter);
+			raw_show(&ss_current_filter);
 	}
-	if (current_filter.dbs & (1<<UDP_DB)) {
+	if (ss_current_filter.dbs & (1<<UDP_DB)) {
 		if (json_output) {
 			printf("\"UDP\": [\n");
-			udp_show(&current_filter);
+			udp_show(&ss_current_filter);
 			json_first_elem = 1;
 			res_json_fmt_branch(
-					current_filter.dbs & (1<<TCP_DB) ||
-					current_filter.dbs & (1<<DCCP_DB), ']');
+					ss_current_filter.dbs & (1<<TCP_DB) ||
+					ss_current_filter.dbs & (1<<DCCP_DB), ']');
 
 		} else
-			udp_show(&current_filter);
+			udp_show(&ss_current_filter);
 	}
-	if (current_filter.dbs & (1<<TCP_DB)) {
+	if (ss_current_filter.dbs & (1<<TCP_DB)) {
 		if (json_output) {
 			printf("\"TCP\": [\n");
-			tcp_show(&current_filter, IPPROTO_TCP);
+			tcp_show(&ss_current_filter, IPPROTO_TCP);
 			json_first_elem = 1;
 			res_json_fmt_branch(
-					current_filter.dbs & (1<<DCCP_DB), ']');
+					ss_current_filter.dbs & (1<<DCCP_DB), ']');
 		} else
-			tcp_show(&current_filter, IPPROTO_TCP);
+			tcp_show(&ss_current_filter, IPPROTO_TCP);
 	}
-	if (current_filter.dbs & (1<<DCCP_DB)) {
+	if (ss_current_filter.dbs & (1<<DCCP_DB)) {
 		if (json_output) {
 			printf("\"DCCP\": [\n");
-			tcp_show(&current_filter, IPPROTO_DCCP);
+			tcp_show(&ss_current_filter, IPPROTO_DCCP);
 			printf("]\n");
 		} else
-			tcp_show(&current_filter, IPPROTO_DCCP);
+			tcp_show(&ss_current_filter, IPPROTO_DCCP);
 	}
 
 	if (json_output)
@@ -3637,7 +3637,7 @@ int main(int argc, char *argv[])
 	fflush(stdout);
 
 	if (follow_events)
-		exit(handle_follow_request(&current_filter));
+		exit(handle_follow_request(&ss_current_filter));
 
 	if (show_users || show_proc_ctx || show_sock_ctx)
 		user_ent_destroy();
-- 
1.9.1
