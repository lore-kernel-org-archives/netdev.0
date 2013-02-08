From: Kees van Reeuwijk <kees.van.reeuwijk@gmail.com>
Subject: [PATCH v2 5/5] iproute2: improved error messages
Date: Fri, 08 Feb 2013 14:32:36 +0100
Message-ID: <E1U3o4C-0000c3-OZ@babylon.few.vu.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:62547 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946022Ab3BHNek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 08:34:40 -0500
Received: by mail-wg0-f46.google.com with SMTP id fg15so2898714wgb.13
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2013 05:34:38 -0800 (PST)
Received: from reeuwijk by babylon.few.vu.nl with local (Exim 4.72)
	(envelope-from <reeuwijk@few.vu.nl>)
	id 1U3o4C-0000c3-OZ
	for netdev@vger.kernel.org; Fri, 08 Feb 2013 14:32:36 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kees van Reeuwijk <reeuwijk@few.vu.nl>

This patch improves many error messages as follows:
- For incorrect parameters, show the value of the offending parameter, rather than just say that it is incorrect
- Rephrased messages for clarity
- Rephrased to more `mainstream' english


Signed-off-by: Kees van Reeuwijk <reeuwijk@few.vu.nl>

---


 ip6tunnel.c      |    8 ++++----
 ipaddress.c      |    2 +-
 ipl2tp.c         |    2 +-
 iplink.c         |   28 ++++++++++++++--------------
 iplink_can.c     |    6 +++---
 iplink_ipoib.c   |    2 +-
 iplink_macvlan.c |    2 +-
 iplink_macvtap.c |    8 ++++----
 iplink_vlan.c    |   12 ++++++------
 iplink_vxlan.c   |    2 +-
 ipnetns.c        |   20 ++++++++++----------
 ipprefix.c       |    2 +-
 iproute.c        |    4 ++--
 iptunnel.c       |   30 +++++++++++++++---------------
 iptuntap.c       |    2 +-
 ipxfrm.c         |    2 +-
 link_gre.c       |    8 ++++----
 link_vti.c       |   10 +++++-----
 tcp_metrics.c    |    2 +-
 tunnel.c         |    6 +++---
 20 files changed, 79 insertions(+), 79 deletions(-)

diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index fcc9f33..216e982 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -128,7 +128,7 @@ static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm *p)
 				 strcmp(*argv, "any") == 0)
 				p->proto = 0;
 			else {
-                                fprintf(stderr,"Cannot guess tunnel mode.\n");
+                                fprintf(stderr,"Unknown tunnel mode \"%s\"\n", *argv);
                                 exit(-1);
                         }
                 } else if (strcmp(*argv, "remote") == 0) {
@@ -293,7 +293,7 @@ static int do_tunnels_list(struct ip6_tnl_parm *p)
 		buf[sizeof(buf) - 1] = '\0';
 		if ((ptr = strchr(buf, ':')) == NULL ||
 		    (*ptr++ = 0, sscanf(buf, "%s", name) != 1)) {
-			fprintf(stderr, "Wrong format of /proc/net/dev. Sorry.\n");
+			fprintf(stderr, "Wrong format for /proc/net/dev. Giving up.\n");
 			goto end;
 		}
 		if (sscanf(ptr, "%ld%ld%ld%ld%ld%ld%ld%*d%ld%ld%ld%ld%ld%ld%ld",
@@ -309,7 +309,7 @@ static int do_tunnels_list(struct ip6_tnl_parm *p)
 			continue;
 		type = ll_index_to_type(index);
 		if (type == -1) {
-			fprintf(stderr, "Failed to get type of [%s]\n", name);
+			fprintf(stderr, "Failed to get type of \"%s\"\n", name);
 			continue;
 		}
 		if (type != ARPHRD_TUNNEL6)
@@ -402,7 +402,7 @@ int do_ip6tunnel(int argc, char **argv)
 	case AF_INET6:
 		break;
 	default:
-		fprintf(stderr, "Unsupported family:%d\n", preferred_family);
+		fprintf(stderr, "Unsupported protocol family: %d\n", preferred_family);
 		exit(-1);
 	}
 
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 297506d..0bd8a76 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -785,7 +785,7 @@ static int ipadd_save_prep(void)
 	int ret;
 
 	if (isatty(STDOUT_FILENO)) {
-		fprintf(stderr, "Not sending binary stream to stdout\n");
+		fprintf(stderr, "Not sending a binary stream to stdout\n");
 		return -1;
 	}
 
diff --git a/ip/ipl2tp.c b/ip/ipl2tp.c
index f6e264a..2d22317 100644
--- a/ip/ipl2tp.c
+++ b/ip/ipl2tp.c
@@ -494,7 +494,7 @@ static int parse_args(int argc, char **argv, int cmd, struct l2tp_parm *p)
 			} else if (strcmp(*argv, "udp") == 0) {
 				p->encap = L2TP_ENCAPTYPE_UDP;
 			} else {
-				fprintf(stderr, "Unknown tunnel encapsulation.\n");
+				fprintf(stderr, "Unknown tunnel encapsulation \"%s\"\n", *argv);
 				exit(-1);
 			}
 		} else if (strcmp(*argv, "name") == 0) {
diff --git a/ip/iplink.c b/ip/iplink.c
index 5ff8f85..c24f0ce 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -94,9 +94,9 @@ static void usage(void)
 	iplink_usage();
 }
 
-static int on_off(char *msg)
+static int on_off(const char *msg, const char *realval)
 {
-	fprintf(stderr, "Error: argument of \"%s\" must be \"on\" or \"off\"\n", msg);
+	fprintf(stderr, "Error: argument of \"%s\" must be \"on\" or \"off\", not \"%s\"\n", msg, realval);
 	return -1;
 }
 
@@ -348,7 +348,7 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 			} else if (strcmp(*argv, "off") == 0) {
 				req->i.ifi_flags &= ~IFF_MULTICAST;
 			} else
-				return on_off("multicast");
+				return on_off("multicast", *argv);
 		} else if (strcmp(*argv, "allmulticast") == 0) {
 			NEXT_ARG();
 			req->i.ifi_change |= IFF_ALLMULTI;
@@ -357,7 +357,7 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 			} else if (strcmp(*argv, "off") == 0) {
 				req->i.ifi_flags &= ~IFF_ALLMULTI;
 			} else
-				return on_off("allmulticast");
+				return on_off("allmulticast", *argv);
 		} else if (strcmp(*argv, "promisc") == 0) {
 			NEXT_ARG();
 			req->i.ifi_change |= IFF_PROMISC;
@@ -366,7 +366,7 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 			} else if (strcmp(*argv, "off") == 0) {
 				req->i.ifi_flags &= ~IFF_PROMISC;
 			} else
-				return on_off("promisc");
+				return on_off("promisc", *argv);
 		} else if (strcmp(*argv, "trailers") == 0) {
 			NEXT_ARG();
 			req->i.ifi_change |= IFF_NOTRAILERS;
@@ -375,7 +375,7 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 			} else if (strcmp(*argv, "on") == 0) {
 				req->i.ifi_flags &= ~IFF_NOTRAILERS;
 			} else
-				return on_off("trailers");
+				return on_off("trailers", *argv);
 		} else if (strcmp(*argv, "arp") == 0) {
 			NEXT_ARG();
 			req->i.ifi_change |= IFF_NOARP;
@@ -384,7 +384,7 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 			} else if (strcmp(*argv, "off") == 0) {
 				req->i.ifi_flags |= IFF_NOARP;
 			} else
-				return on_off("noarp");
+				return on_off("noarp", *argv);
 		} else if (strcmp(*argv, "vf") == 0) {
 			struct rtattr *vflist;
 			NEXT_ARG();
@@ -417,7 +417,7 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 			} else if (strcmp(*argv, "off") == 0) {
 				req->i.ifi_flags &= ~IFF_DYNAMIC;
 			} else
-				return on_off("dynamic");
+				return on_off("dynamic", *argv);
 		} else if (matches(*argv, "type") == 0) {
 			NEXT_ARG();
 			*type = *argv;
@@ -852,7 +852,7 @@ static int do_set(int argc, char **argv)
 			} else if (strcmp(*argv, "off") == 0) {
 				flags &= ~IFF_MULTICAST;
 			} else
-				return on_off("multicast");
+				return on_off("multicast", *argv);
 		} else if (strcmp(*argv, "allmulticast") == 0) {
 			NEXT_ARG();
 			mask |= IFF_ALLMULTI;
@@ -861,7 +861,7 @@ static int do_set(int argc, char **argv)
 			} else if (strcmp(*argv, "off") == 0) {
 				flags &= ~IFF_ALLMULTI;
 			} else
-				return on_off("allmulticast");
+				return on_off("allmulticast", *argv);
 		} else if (strcmp(*argv, "promisc") == 0) {
 			NEXT_ARG();
 			mask |= IFF_PROMISC;
@@ -870,7 +870,7 @@ static int do_set(int argc, char **argv)
 			} else if (strcmp(*argv, "off") == 0) {
 				flags &= ~IFF_PROMISC;
 			} else
-				return on_off("promisc");
+				return on_off("promisc", *argv);
 		} else if (strcmp(*argv, "trailers") == 0) {
 			NEXT_ARG();
 			mask |= IFF_NOTRAILERS;
@@ -879,7 +879,7 @@ static int do_set(int argc, char **argv)
 			} else if (strcmp(*argv, "on") == 0) {
 				flags &= ~IFF_NOTRAILERS;
 			} else
-				return on_off("trailers");
+				return on_off("trailers", *argv);
 		} else if (strcmp(*argv, "arp") == 0) {
 			NEXT_ARG();
 			mask |= IFF_NOARP;
@@ -888,7 +888,7 @@ static int do_set(int argc, char **argv)
 			} else if (strcmp(*argv, "off") == 0) {
 				flags |= IFF_NOARP;
 			} else
-				return on_off("noarp");
+				return on_off("noarp", *argv);
 		} else if (matches(*argv, "dynamic") == 0) {
 			NEXT_ARG();
 			mask |= IFF_DYNAMIC;
@@ -897,7 +897,7 @@ static int do_set(int argc, char **argv)
 			} else if (strcmp(*argv, "off") == 0) {
 				flags &= ~IFF_DYNAMIC;
 			} else
-				return on_off("dynamic");
+				return on_off("dynamic", *argv);
 		} else {
                         if (strcmp(*argv, "dev") == 0) {
 				NEXT_ARG();
diff --git a/ip/iplink_can.c b/ip/iplink_can.c
index c8af4bc..5674358 100644
--- a/ip/iplink_can.c
+++ b/ip/iplink_can.c
@@ -68,8 +68,8 @@ static void set_ctrlmode(char* name, char *arg,
 		cm->flags |= flags;
 	} else if (strcmp(arg, "off") != 0) {
 		fprintf(stderr,
-			"Error: argument of \"%s\" must be \"on\" or \"off\"\n",
-			name);
+			"Error: argument of \"%s\" must be \"on\" or \"off\", not \"%s\"\n",
+			name, arg);
 		exit(-1);
 	}
 	cm->mask |= flags;
@@ -169,7 +169,7 @@ static int can_parse_opt(struct link_util *lu, int argc, char **argv,
 			usage();
 			return -1;
 		} else {
-			fprintf(stderr, "can: what is \"%s\"?\n", *argv);
+			fprintf(stderr, "can: unknown option \"%s\"\n", *argv);
 			usage();
 			return -1;
 		}
diff --git a/ip/iplink_ipoib.c b/ip/iplink_ipoib.c
index ae372bc..5c1c68c 100644
--- a/ip/iplink_ipoib.c
+++ b/ip/iplink_ipoib.c
@@ -66,7 +66,7 @@ static int ipoib_parse_opt(struct link_util *lu, int argc, char **argv,
 			explain();
 			return -1;
 		} else {
-			fprintf(stderr, "ipoib: what is \"%s\"?\n", *argv);
+			fprintf(stderr, "ipoib: unknown option \"%s\"?\n", *argv);
 			explain();
 			return -1;
 		}
diff --git a/ip/iplink_macvlan.c b/ip/iplink_macvlan.c
index ed0e34b..5b4b868 100644
--- a/ip/iplink_macvlan.c
+++ b/ip/iplink_macvlan.c
@@ -58,7 +58,7 @@ static int macvlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			explain();
 			return -1;
 		} else {
-			fprintf(stderr, "macvlan: what is \"%s\"?\n", *argv);
+			fprintf(stderr, "macvlan: unknown option \"%s\"?\n", *argv);
 			explain();
 			return -1;
 		}
diff --git a/ip/iplink_macvtap.c b/ip/iplink_macvtap.c
index 6c7fe1f..bea9f0c 100644
--- a/ip/iplink_macvtap.c
+++ b/ip/iplink_macvtap.c
@@ -24,10 +24,10 @@ static void explain(void)
 	);
 }
 
-static int mode_arg(void)
+static int mode_arg(const char *arg)
 {
         fprintf(stderr, "Error: argument of \"mode\" must be \"private\", "
-		"\"vepa\", \"bridge\" or \"passthru\" \n");
+		"\"vepa\", \"bridge\" or \"passthru\", not \"%s\"\n", arg);
         return -1;
 }
 
@@ -48,14 +48,14 @@ static int macvtap_parse_opt(struct link_util *lu, int argc, char **argv,
 			else if (strcmp(*argv, "passthru") == 0)
 				mode = MACVLAN_MODE_PASSTHRU;
 			else
-				return mode_arg();
+				return mode_arg(*argv);
 
 			addattr32(n, 1024, IFLA_MACVLAN_MODE, mode);
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
 		} else {
-			fprintf(stderr, "macvtap: what is \"%s\"?\n", *argv);
+			fprintf(stderr, "macvtap: unknown command \"%s\"?\n", *argv);
 			explain();
 			return -1;
 		}
diff --git a/ip/iplink_vlan.c b/ip/iplink_vlan.c
index 97af8d6..26ceb8d 100644
--- a/ip/iplink_vlan.c
+++ b/ip/iplink_vlan.c
@@ -33,9 +33,9 @@ static void explain(void)
 	);
 }
 
-static int on_off(char *msg)
+static int on_off(const char *msg, const char *arg)
 {
-	fprintf(stderr, "Error: argument of \"%s\" must be \"on\" or \"off\"\n", msg);
+	fprintf(stderr, "Error: argument of \"%s\" must be \"on\" or \"off\", not \"%s\"\n", msg, arg);
 	return -1;
 }
 
@@ -93,7 +93,7 @@ static int vlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			else if (strcmp(*argv, "off") == 0)
 				flags.flags &= ~VLAN_FLAG_REORDER_HDR;
 			else
-				return on_off("reorder_hdr");
+				return on_off("reorder_hdr", *argv);
 		} else if (matches(*argv, "gvrp") == 0) {
 			NEXT_ARG();
 			flags.mask |= VLAN_FLAG_GVRP;
@@ -102,7 +102,7 @@ static int vlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			else if (strcmp(*argv, "off") == 0)
 				flags.flags &= ~VLAN_FLAG_GVRP;
 			else
-				return on_off("gvrp");
+				return on_off("gvrp", *argv);
 		} else if (matches(*argv, "loose_binding") == 0) {
 			NEXT_ARG();
 			flags.mask |= VLAN_FLAG_LOOSE_BINDING;
@@ -111,7 +111,7 @@ static int vlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			else if (strcmp(*argv, "off") == 0)
 				flags.flags &= ~VLAN_FLAG_LOOSE_BINDING;
 			else
-				return on_off("loose_binding");
+				return on_off("loose_binding", *argv);
 		} else if (matches(*argv, "ingress-qos-map") == 0) {
 			NEXT_ARG();
 			if (vlan_parse_qos_map(&argc, &argv, n,
@@ -128,7 +128,7 @@ static int vlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			explain();
 			return -1;
 		} else {
-			fprintf(stderr, "vlan: what is \"%s\"?\n", *argv);
+			fprintf(stderr, "vlan: unknown command \"%s\"?\n", *argv);
 			explain();
 			return -1;
 		}
diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index 4b72361..1025326 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -149,7 +149,7 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			explain();
 			return -1;
 		} else {
-			fprintf(stderr, "vxlan: what is \"%s\"?\n", *argv);
+			fprintf(stderr, "vxlan: unknown command \"%s\"?\n", *argv);
 			explain();
 			return -1;
 		}
diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 51b1c5e..b047b97 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -130,7 +130,7 @@ static int netns_exec(int argc, char **argv)
 		return EXIT_FAILURE;
 	}
 	if (argc < 2) {
-		fprintf(stderr, "No cmd specified\n");
+		fprintf(stderr, "No command specified\n");
 		return EXIT_FAILURE;
 	}
 	name = argv[0];
@@ -138,13 +138,13 @@ static int netns_exec(int argc, char **argv)
 	snprintf(net_path, sizeof(net_path), "%s/%s", NETNS_RUN_DIR, name);
 	netns = open(net_path, O_RDONLY);
 	if (netns < 0) {
-		fprintf(stderr, "Cannot open network namespace %s: %s\n",
+		fprintf(stderr, "Cannot open network namespace \"%s\": %s\n",
 			name, strerror(errno));
 		return EXIT_FAILURE;
 	}
 	if (setns(netns, CLONE_NEWNET) < 0) {
-		fprintf(stderr, "seting the network namespace failed: %s\n",
-			strerror(errno));
+		fprintf(stderr, "seting the network namespace \"%s\" failed: %s\n",
+			name, strerror(errno));
 		return EXIT_FAILURE;
 	}
 
@@ -154,7 +154,7 @@ static int netns_exec(int argc, char **argv)
 	}
 	/* Don't let any mounts propogate back to the parent */
 	if (mount("", "/", "none", MS_SLAVE | MS_REC, NULL)) {
-		fprintf(stderr, "mount --make-rslave / failed: %s\n",
+		fprintf(stderr, "\"mount --make-rslave /\" failed: %s\n",
 			strerror(errno));
 		return EXIT_FAILURE;
 	}
@@ -172,7 +172,7 @@ static int netns_exec(int argc, char **argv)
 	bind_etc(name);
 
 	if (execvp(cmd, argv + 1)  < 0)
-		fprintf(stderr, "exec of %s failed: %s\n",
+		fprintf(stderr, "exec of \"%s\" failed: %s\n",
 			cmd, strerror(errno));
 	return EXIT_FAILURE;
 }
@@ -330,7 +330,7 @@ static int netns_delete(int argc, char **argv)
 	snprintf(netns_path, sizeof(netns_path), "%s/%s", NETNS_RUN_DIR, name);
 	umount2(netns_path, MNT_DETACH);
 	if (unlink(netns_path) < 0) {
-		fprintf(stderr, "Cannot remove %s: %s\n",
+		fprintf(stderr, "Cannot remove namespace file \"%s\": %s\n",
 			netns_path, strerror(errno));
 		return EXIT_FAILURE;
 	}
@@ -389,14 +389,14 @@ static int netns_add(int argc, char **argv)
 	/* Create the filesystem state */
 	fd = open(netns_path, O_RDONLY|O_CREAT|O_EXCL, 0);
 	if (fd < 0) {
-		fprintf(stderr, "Could not create %s: %s\n",
+		fprintf(stderr, "Cannot not create namespace file \"%s\": %s\n",
 			netns_path, strerror(errno));
 		return EXIT_FAILURE;
 	}
 	close(fd);
 	if (unshare(CLONE_NEWNET) < 0) {
-		fprintf(stderr, "Failed to create a new network namespace: %s\n",
-			strerror(errno));
+		fprintf(stderr, "Failed to create a new network namespace \"%s\": %s\n",
+			name, strerror(errno));
 		goto out_delete;
 	}
 
diff --git a/ip/ipprefix.c b/ip/ipprefix.c
index ee276b3..cf68f89 100644
--- a/ip/ipprefix.c
+++ b/ip/ipprefix.c
@@ -60,7 +60,7 @@ int print_prefix(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		return 0;
 
 	if (prefix->prefix_family != AF_INET6) {
-		fprintf(stderr, "wrong family %d\n", prefix->prefix_family);
+		fprintf(stderr, "incorrect protocol family: %d\n", prefix->prefix_family);
 		return 0;
 	}
 	if (prefix->prefix_type != ND_OPT_PREFIX_INFORMATION) {
diff --git a/ip/iproute.c b/ip/iproute.c
index c60156f..309cc87 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -1099,7 +1099,7 @@ static int save_route_prep(void)
 	int ret;
 
 	if (isatty(STDOUT_FILENO)) {
-		fprintf(stderr, "Not sending binary stream to stdout\n");
+		fprintf(stderr, "Not sending a binary stream to stdout\n");
 		return -1;
 	}
 
@@ -1445,7 +1445,7 @@ int iproute_get(int argc, char **argv)
 	}
 
 	if (req.r.rtm_dst_len == 0) {
-		fprintf(stderr, "need at least destination address\n");
+		fprintf(stderr, "need at least a destination address\n");
 		exit(1);
 	}
 
diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index f8b91ba..4275f26 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -102,7 +102,7 @@ static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 				p->iph.protocol = IPPROTO_IPIP;
 				p->i_flags |= VTI_ISVTI;
 			} else {
-				fprintf(stderr,"Cannot guess tunnel mode.\n");
+				fprintf(stderr,"Unknown tunnel mode \"%s\"\n", *argv);
 				exit(-1);
 			}
 		} else if (strcmp(*argv, "key") == 0) {
@@ -114,7 +114,7 @@ static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 				p->i_key = p->o_key = get_addr32(*argv);
 			else {
 				if (get_unsigned(&uval, *argv, 0)<0) {
-					fprintf(stderr, "invalid value of \"key\"\n");
+					fprintf(stderr, "invalid value for \"key\": \"%s\"; it should be an unsigned integer\n", *argv);
 					exit(-1);
 				}
 				p->i_key = p->o_key = htonl(uval);
@@ -127,7 +127,7 @@ static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 				p->i_key = get_addr32(*argv);
 			else {
 				if (get_unsigned(&uval, *argv, 0)<0) {
-					fprintf(stderr, "invalid value of \"ikey\"\n");
+					fprintf(stderr, "invalid value for \"ikey\": \"%s\"; it should be an unsigned integer\n", *argv);
 					exit(-1);
 				}
 				p->i_key = htonl(uval);
@@ -140,7 +140,7 @@ static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 				p->o_key = get_addr32(*argv);
 			else {
 				if (get_unsigned(&uval, *argv, 0)<0) {
-					fprintf(stderr, "invalid value of \"okey\"\n");
+					fprintf(stderr, "invalid value for \"okey\": \"%s\"; it should be an unsigned integer\n", *argv);
 					exit(-1);
 				}
 				p->o_key = htonl(uval);
@@ -242,7 +242,7 @@ static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 
 	if (p->iph.protocol == IPPROTO_IPIP || p->iph.protocol == IPPROTO_IPV6) {
 		if ((p->i_flags & GRE_KEY) || (p->o_flags & GRE_KEY)) {
-			fprintf(stderr, "Keys are not allowed with ipip and sit.\n");
+			fprintf(stderr, "Keys are not allowed with ipip and sit tunnels\n");
 			return -1;
 		}
 	}
@@ -262,7 +262,7 @@ static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 		p->o_flags |= GRE_KEY;
 	}
 	if (IN_MULTICAST(ntohl(p->iph.daddr)) && !p->iph.saddr) {
-		fprintf(stderr, "Broadcast tunnel requires a source address.\n");
+		fprintf(stderr, "A broadcast tunnel requires a source address\n");
 		return -1;
 	}
 	if (isatap)
@@ -444,7 +444,7 @@ static int do_tunnels_list(struct ip_tunnel_parm *p)
 		buf[sizeof(buf) - 1] = 0;
 		if ((ptr = strchr(buf, ':')) == NULL ||
 		    (*ptr++ = 0, sscanf(buf, "%s", name) != 1)) {
-			fprintf(stderr, "Wrong format of /proc/net/dev. Sorry.\n");
+			fprintf(stderr, "Wrong format for /proc/net/dev. Giving up.\n");
 			fclose(fp);
 			return -1;
 		}
@@ -461,7 +461,7 @@ static int do_tunnels_list(struct ip_tunnel_parm *p)
 			continue;
 		type = ll_index_to_type(index);
 		if (type == -1) {
-			fprintf(stderr, "Failed to get type of [%s]\n", name);
+			fprintf(stderr, "Failed to get type of \"%s\"\n", name);
 			continue;
 		}
 		if (type != ARPHRD_TUNNEL && type != ARPHRD_IPGRE && type != ARPHRD_SIT)
@@ -558,17 +558,17 @@ static int do_prl(int argc, char **argv)
 			strncpy(medium, *argv, IFNAMSIZ-1);
 			devname++;
 		} else {
-			fprintf(stderr,"%s: Invalid PRL parameter.\n", *argv);
+			fprintf(stderr,"Invalid PRL parameter \"%s\"\n", *argv);
 			exit(-1);
 		}
 		if (count > 1) {
-			fprintf(stderr,"One PRL entry at a time.\n");
+			fprintf(stderr,"One PRL entry at a time\n");
 			exit(-1);
 		}
 		argc--; argv++;
 	}
 	if (devname == 0) {
-		fprintf(stderr, "Must specify dev.\n");
+		fprintf(stderr, "Must specify device\n");
 		exit(-1);
 	}
 
@@ -608,13 +608,13 @@ static int do_6rd(int argc, char **argv)
 			strncpy(medium, *argv, IFNAMSIZ-1);
 			devname++;
 		} else {
-			fprintf(stderr,"%s: Invalid 6RD parameter.\n", *argv);
+			fprintf(stderr,"Invalid 6RD parameter \"%s\"\n", *argv);
 			exit(-1);
 		}
 		argc--; argv++;
 	}
 	if (devname == 0) {
-		fprintf(stderr, "Must specify dev.\n");
+		fprintf(stderr, "Must specify device\n");
 		exit(-1);
 	}
 
@@ -637,7 +637,7 @@ int do_iptunnel(int argc, char **argv)
 	case AF_INET6:
 		return do_ip6tunnel(argc, argv);
 	default:
-		fprintf(stderr, "Unsupported family:%d\n", preferred_family);
+		fprintf(stderr, "Unsupported protocol family: %d\n", preferred_family);
 		exit(-1);
 	}
 
@@ -661,6 +661,6 @@ int do_iptunnel(int argc, char **argv)
 	} else
 		return do_show(0, NULL);
 
-	fprintf(stderr, "Command \"%s\" is unknown, try \"ip tunnel help\".\n", *argv);
+	fprintf(stderr, "Command \"%s\" is unknown, try \"ip tunnel help\"\n", *argv);
 	exit(-1);
 }
diff --git a/ip/iptuntap.c b/ip/iptuntap.c
index 20914e1..3d9ad7d 100644
--- a/ip/iptuntap.c
+++ b/ip/iptuntap.c
@@ -128,7 +128,7 @@ static int parse_args(int argc, char **argv, struct ifreq *ifr, uid_t *uid, gid_
 				}
 				ifr->ifr_flags |= IFF_TAP;
 			} else {
-				fprintf(stderr,"Cannot guess tunnel mode.\n");
+				fprintf(stderr,"Unknown tunnel mode \"%s\"\n", *argv);
 				exit(-1);
 			}
 		} else if (uid && matches(*argv, "user") == 0) {
diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index dda4a7a..5a0f215 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -1231,7 +1231,7 @@ static int xfrm_selector_upspec_parse(struct xfrm_selector *sel,
 				uval = htonl(get_addr32(*argv));
 			else {
 				if (get_unsigned(&uval, *argv, 0)<0) {
-					fprintf(stderr, "invalid value of \"key\"\n");
+					fprintf(stderr, "invalid value for \"key\"; it should be an unsigned integer\n");
 					exit(-1);
 				}
 			}
diff --git a/ip/link_gre.c b/ip/link_gre.c
index 839fb29..7e0b896 100644
--- a/ip/link_gre.c
+++ b/ip/link_gre.c
@@ -141,7 +141,7 @@ get_failed:
 			else {
 				if (get_unsigned(&uval, *argv, 0) < 0) {
 					fprintf(stderr,
-						"Invalid value for \"key\"\n");
+						"Invalid value for \"key\": \"%s\"; it should be an unsigned integer\n", *argv);
 					exit(-1);
 				}
 				uval = htonl(uval);
@@ -157,7 +157,7 @@ get_failed:
 				uval = get_addr32(*argv);
 			else {
 				if (get_unsigned(&uval, *argv, 0)<0) {
-					fprintf(stderr, "invalid value of \"ikey\"\n");
+					fprintf(stderr, "invalid value for \"ikey\": \"%s\"; it should be an unsigned integer\n", *argv);
 					exit(-1);
 				}
 				uval = htonl(uval);
@@ -172,7 +172,7 @@ get_failed:
 				uval = get_addr32(*argv);
 			else {
 				if (get_unsigned(&uval, *argv, 0)<0) {
-					fprintf(stderr, "invalid value of \"okey\"\n");
+					fprintf(stderr, "invalid value for \"okey\": \"%s\"; it should be an unsigned integer\n", *argv);
 					exit(-1);
 				}
 				uval = htonl(uval);
@@ -247,7 +247,7 @@ get_failed:
 		oflags |= GRE_KEY;
 	}
 	if (IN_MULTICAST(ntohl(daddr)) && !saddr) {
-		fprintf(stderr, "Broadcast tunnel requires a source address.\n");
+		fprintf(stderr, "A broadcast tunnel requires a source address.\n");
 		return -1;
 	}
 
diff --git a/ip/link_vti.c b/ip/link_vti.c
index 385f435..77a7482 100644
--- a/ip/link_vti.c
+++ b/ip/link_vti.c
@@ -117,7 +117,7 @@ get_failed:
 			else {
 				if (get_unsigned(&uval, *argv, 0) < 0) {
 					fprintf(stderr,
-						"Invalid value for \"key\"\n");
+						"Invalid value for \"key\": \"%s\"; it should be an unsigned integer\n", *argv);
 					exit(-1);
 				}
 				uval = htonl(uval);
@@ -132,7 +132,7 @@ get_failed:
 				uval = get_addr32(*argv);
 			else {
 				if (get_unsigned(&uval, *argv, 0) < 0) {
-					fprintf(stderr, "invalid value of \"ikey\"\n");
+					fprintf(stderr, "invalid value for \"ikey\": \"%s\"; it should be an unsigned integer\n", *argv);
 					exit(-1);
 				}
 				uval = htonl(uval);
@@ -146,7 +146,7 @@ get_failed:
 				uval = get_addr32(*argv);
 			else {
 				if (get_unsigned(&uval, *argv, 0) < 0) {
-					fprintf(stderr, "invalid value of \"okey\"\n");
+					fprintf(stderr, "invalid value for \"okey\": \"%s\"; it should be an unsigned integer\n", *argv);
 					exit(-1);
 				}
 				uval = htonl(uval);
@@ -155,7 +155,7 @@ get_failed:
 		} else if (!matches(*argv, "remote")) {
 			NEXT_ARG();
 			if (!strcmp(*argv, "any")) {
-				fprintf(stderr, "invalid value of \"remote\"\n");
+				fprintf(stderr, "invalid value for \"remote\": \"%s\"\n", *argv);
 				exit(-1);
 			} else {
 				daddr = get_addr32(*argv);
@@ -163,7 +163,7 @@ get_failed:
 		} else if (!matches(*argv, "local")) {
 			NEXT_ARG();
 			if (!strcmp(*argv, "any")) {
-				fprintf(stderr, "invalid value of \"local\"\n");
+				fprintf(stderr, "invalid value for \"local\": \"%s\"\n", *argv);
 				exit(-1);
 			} else {
 				saddr = get_addr32(*argv);
diff --git a/ip/tcp_metrics.c b/ip/tcp_metrics.c
index 34e1d8e..a01e1fb 100644
--- a/ip/tcp_metrics.c
+++ b/ip/tcp_metrics.c
@@ -268,7 +268,7 @@ static int tcpm_do_cmd(int cmd, int argc, char **argv)
 	case AF_INET6:
 		break;
 	default:
-		fprintf(stderr, "Unsupported family:%d\n", preferred_family);
+		fprintf(stderr, "Unsupported protocol family: %d\n", preferred_family);
 		return -1;
 	}
 
diff --git a/ip/tunnel.c b/ip/tunnel.c
index b176d3f..a6a2846 100644
--- a/ip/tunnel.c
+++ b/ip/tunnel.c
@@ -74,7 +74,7 @@ int tnl_get_ioctl(const char *basedev, void *p)
 	fd = socket(preferred_family, SOCK_DGRAM, 0);
 	err = ioctl(fd, SIOCGETTUNNEL, &ifr);
 	if (err)
-		fprintf(stderr, "get tunnel %s failed: %s\n", basedev, 
+		fprintf(stderr, "get tunnel \"%s\" failed: %s\n", basedev,
 			strerror(errno));
 
 	close(fd);
@@ -95,7 +95,7 @@ int tnl_add_ioctl(int cmd, const char *basedev, const char *name, void *p)
 	fd = socket(preferred_family, SOCK_DGRAM, 0);
 	err = ioctl(fd, cmd, &ifr);
 	if (err)
-		fprintf(stderr, "add tunnel %s failed: %s\n", ifr.ifr_name,
+		fprintf(stderr, "add tunnel \"%s\" failed: %s\n", ifr.ifr_name,
 			strerror(errno));
 	close(fd);
 	return err;
@@ -116,7 +116,7 @@ int tnl_del_ioctl(const char *basedev, const char *name, void *p)
 	fd = socket(preferred_family, SOCK_DGRAM, 0);
 	err = ioctl(fd, SIOCDELTUNNEL, &ifr);
 	if (err)
-		fprintf(stderr, "delete tunnel %s failed: %s\n",
+		fprintf(stderr, "delete tunnel \"%s\" failed: %s\n",
 			ifr.ifr_name, strerror(errno));
 	close(fd);
 	return err;
