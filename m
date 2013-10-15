From: Arvid Brodin <arvid.brodin@xdin.com>
Subject: Re: net/hsr Patch - Help
Date: Tue, 15 Oct 2013 21:27:29 +0200
Message-ID: <525D9721.9020402@xdin.com>
References: <52299175.90302@ehu.es> <522E1035.2050503@xdin.com> <525CF1F3.2050006@ehu.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Javier Boticario <jboticario@gmail.com>,
	balferreira <balferreira@googlemail.com>,
	Joe Perches <joe@perches.com>
To: =?ISO-8859-1?Q?El=EDas_Molina_Mu=F1oz?= <elias.molina@ehu.es>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:54362 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932647Ab3JOT1c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Oct 2013 15:27:32 -0400
In-Reply-To: <525CF1F3.2050006@ehu.es>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-10-15 09:42, El=EDas Molina Mu=F1oz wrote:
> El 09/09/2013 20:15, Arvid Brodin escribi=F3:
>> On 2013-09-06 10:25, El=EDas Molina Mu=F1oz wrote:
>>> Dear Mr. Brodin,
>>>=20
>>> I would like to introduce myself. My name is El=EDas Molina, PhD.=20
>>> Student at University of Basque Country (Spain). I am writing to=20
>>> enquire about your HSR patch.
>> Hi!
>>=20
>>> I have read "This is a patch against net-next (2013-08-21)" in
>>> its last version (v3) so I have tried with several kernel
>>> versions but I do not know which is the repo's correct version
>>> of=20
>>> http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/
>>> .
>>>=20
>>> Could you tell me which is the kernel version to apply your
>>> patch?
>> I made an error when I sent that patch, so it won't apply to any
>> kernel version.
>>=20
>> The below patch should work (cd to the net-next directory and apply
>> with patch -Np1):
>>=20
[removed]

> Dear Mr. Brodin,
> =20
> Thanks for getting back to me and I apologize for being so late
> replying.
> =20
> I am writing to enquire if, once compiled the kernel with your patch,
> there is a sample application for verifying the correct operation of
> HSR, as you did in http://patchwork.ozlabs.org/patch/191165/ with
> Documentation/networking/hsr/hsr_genl.c
> =20
> Thank you very much. Best regards,
> =20
> El=EDas Molina

Hi again,

I'm CC:ing the netdev list and others who've shown interest in HSR, sin=
ce=20
they might be interested as well.

Yes, I have patches for iproute2 (to make it possible to add HSR device=
s)
and also a "hsrinfo" program which can be used to query an HSR interfac=
e=20
for statistics, and to listen for any HSR errors detected. The hsrinfo=20
program is based on the hsr_genl program that you mention. It requires=20
the libnl3 library.


The hsrinfo program is below (the iproute2 patch was sent in a previous
message). This code is not of the same quality standards as you would=20
expect of a kernel/iproute2 patch. The idea is to re-write it so that i=
t
becomes part of iproute2, but I won't spend time on that unless there i=
s
some progress with the HSR kernel patch.


---
diff -Nurp hsrinfo-a/hsr_netlink.h hsrinfo-b/hsr_netlink.h
--- hsrinfo-a/hsr_netlink.h	1970-01-01 01:00:00.000000000 +0100
+++ hsrinfo-b/hsr_netlink.h	2013-10-15 21:21:09.058960618 +0200
@@ -0,0 +1,72 @@
+/*
+ * Copyright 2011-2013 Autronica Fire and Security AS
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of the GNU General Public License as published by t=
he Free
+ * Software Foundation; either version 2 of the License, or (at your o=
ption)
+ * any later version.
+ *
+ * Author(s):
+ *	2011-2013 Arvid Brodin, arvid.brodin@xdin.com
+ */
+
+#ifndef __HSR_NETLINK_H
+#define __HSR_NETLINK_H
+
+/* attributes */
+enum {
+	HSR_A_UNSPEC,
+	HSR_A_NODE_ADDR,
+	HSR_A_IFINDEX,
+	HSR_A_IF1_AGE,
+	HSR_A_IF2_AGE,
+	HSR_A_NODE_ADDR_B,
+	HSR_A_IF1_SEQ,
+	HSR_A_IF2_SEQ,
+	HSR_A_IF1_IFINDEX,
+	HSR_A_IF2_IFINDEX,
+	HSR_A_ADDR_B_IFINDEX,
+	__HSR_A_MAX,
+};
+#define HSR_A_MAX (__HSR_A_MAX - 1)
+
+
+#ifdef __KERNEL__
+
+#include <linux/if_ether.h>
+#include <linux/module.h>
+
+int __init hsr_netlink_init(void);
+void __exit hsr_netlink_exit(void);
+
+void hsr_nl_ringerror(unsigned char addr[ETH_ALEN], int dev_idx);
+void hsr_nl_nodedown(unsigned char addr[ETH_ALEN]);
+void hsr_nl_framedrop(int dropcount, int dev_idx);
+void hsr_nl_linkdown(int dev_idx);
+
+
+/*
+ * Generic Netlink HSR family definition
+ */
+
+
+#endif /* __KERNEL__ */
+
+
+
+/* commands */
+enum {
+	HSR_C_UNSPEC,
+	HSR_C_RING_ERROR,
+	HSR_C_NODE_DOWN,
+	HSR_C_GET_NODE_STATUS,
+	HSR_C_SET_NODE_STATUS,
+	HSR_C_GET_NODE_LIST,
+	HSR_C_SET_NODE_LIST,
+	__HSR_C_MAX,
+};
+#define HSR_C_MAX (__HSR_C_MAX - 1)
+
+
+
+#endif /* __HSR_NETLINK_H */
diff -Nurp hsrinfo-a/hsrinfo.c hsrinfo-b/hsrinfo.c
--- hsrinfo-a/hsrinfo.c	1970-01-01 01:00:00.000000000 +0100
+++ hsrinfo-b/hsrinfo.c	2013-10-15 21:23:32.983517217 +0200
@@ -0,0 +1,504 @@
+/*
+ * Copyright 2011-2013 Autronica Fire and Security AS
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of the GNU General Public License as published by t=
he Free
+ * Software Foundation; either version 2 of the License, or (at your o=
ption)
+ * any later version.
+ *
+ * Author(s):
+ *	2011-2013 Arvid Brodin, arvid.brodin@xdin.com
+ *
+ * Userspace example of using Generic Netlink (through libnl-3) to get=
 HSR
+ * ("High-availability Seamless Redundancy") link/network status.
+ */
+
+
+/*
+
+Manual static cross-build:
+
+$ PATH=3D[toolchain-path]/usr/bin/:${PATH} avr32-unknown-linux-uclibc-=
gcc -Wall -g -I[toolchain-path]/usr/include/libnl3 -static -L[toolchain=
-path]/usr/lib hsrinfo.c -o hsrinfo -lnl-genl-3 -lnl-3 -pthread -lm
+
+Native build:
+$ gcc -Wall -g -I /usr/include/libnl3/ -lnl-3 -lnl-genl-3 hsrinfo.c -o=
 hsrinfo-x86
+
+*/
+
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <errno.h>
+#include <string.h>
+#include <netlink/netlink.h>
+#include <netlink/socket.h>
+#include <netlink/attr.h>
+#include <netlink/genl/genl.h>
+#include <netlink/genl/ctrl.h>
+#include <net/if.h>
+#include <linux/if_ether.h>
+#include "hsr_netlink.h"
+
+struct node_item {
+	struct node_item *next;
+	unsigned char addr[ETH_ALEN];
+};
+
+static struct node_item *node_head =3D NULL;
+
+static int seq_nr =3D 10;
+
+
+static void nodelist_clear(struct node_item **ni)
+{
+	if (!*ni)
+		return;
+
+	nodelist_clear(&(*ni)->next);
+
+	free(*ni);
+	(*ni) =3D NULL;
+}
+
+static void nodelist_add(struct node_item **head, const char addr[ETH_=
ALEN])
+{
+	struct node_item **ni;
+
+	ni =3D head;
+	while (*ni)
+		ni =3D &(*ni)->next;
+
+	*ni =3D calloc(1, sizeof(struct node_item));
+	if (!*ni)
+		return; // No mem
+
+	memcpy((*ni)->addr, addr, ETH_ALEN);
+}
+
+
+static void print_mac(const unsigned char *addr)
+{
+	int i;
+
+	if (!addr) {
+		printf("(null)           ");
+		return;
+	}
+
+	for (i =3D 0; i < ETH_ALEN - 1; i++)
+		printf("%02x:", addr[i]);
+	printf("%02x", addr[ETH_ALEN - 1]);
+}
+
+
+static void parse_ring_error(struct genlmsghdr *hdr)
+{
+	struct nlattr *attr;
+	unsigned char *AddrA;
+	int ifindex;
+	char ifname[IF_NAMESIZE];
+	char *nameptr;
+
+	printf("Ring error: ");
+
+	AddrA =3D NULL;
+	ifindex =3D -1;
+
+	attr =3D genlmsg_attrdata(hdr, 0);
+	int remaining =3D genlmsg_attrlen(hdr, 0);
+	while (nla_ok(attr, remaining)) {
+		switch (attr->nla_type) {
+		case HSR_A_NODE_ADDR:
+			AddrA =3D nla_data(attr);
+			break;
+		case HSR_A_IFINDEX:
+			ifindex =3D nla_get_u32(attr);
+			break;
+		default:
+			printf("unknown attribute type: %d\n", attr->nla_type);
+		}
+		attr =3D nla_next(attr, &remaining);
+	}
+
+	if (!AddrA) {
+		printf("Error: invalid HSR_C_RING_ERROR packet\n");
+		return;
+	}
+
+	nameptr =3D if_indextoname(ifindex, ifname);
+	if (!nameptr)
+		snprintf(ifname, IF_NAMESIZE, "if%d", ifindex);
+	printf("interface %s, node ", ifname);
+	print_mac(AddrA);
+	printf("\n");
+}
+
+static void parse_node_down(struct genlmsghdr *hdr)
+{
+	struct nlattr *attr;
+	unsigned char *AddrA;
+
+	printf("Node down: ");
+
+	AddrA =3D NULL;
+
+	attr =3D genlmsg_attrdata(hdr, 0);
+	int remaining =3D genlmsg_attrlen(hdr, 0);
+	while (nla_ok(attr, remaining)) {
+		switch (attr->nla_type) {
+		case HSR_A_NODE_ADDR:
+			AddrA =3D nla_data(attr);
+			break;
+		default:
+			printf("unknown attribute type: %d\n", attr->nla_type);
+		}
+		attr =3D nla_next(attr, &remaining);
+	}
+
+	if (!AddrA) {
+		printf("Error: invalid HSR_C_NODE_DOWN packet\n");
+		return;
+	}
+
+	print_mac(AddrA);
+	printf("\n");
+}
+
+static void parse_node_status(struct genlmsghdr *hdr)
+{
+	unsigned char *AddrA, *AddrB;
+	int if1_age, if2_age;
+	int if1_seq, if2_seq;
+	int if1_ifindex, if2_ifindex, addr_b_ifindex;
+	char if1_ifname[IF_NAMESIZE];
+	char if2_ifname[IF_NAMESIZE];
+	char addr_b_ifname[IF_NAMESIZE];
+	char *nameptr;
+	struct nlattr *attr;
+
+	AddrA =3D NULL;
+	AddrB =3D NULL;
+	if1_age =3D -1;
+	if2_age =3D -1;
+	if1_seq =3D -1;
+	if2_seq =3D -1;
+	if1_ifindex =3D -1;
+	if2_ifindex =3D -1;
+	addr_b_ifindex =3D -1;
+
+	attr =3D genlmsg_attrdata(hdr, 0);
+	int remaining =3D genlmsg_attrlen(hdr, 0);
+	while (nla_ok(attr, remaining)) {
+		switch (attr->nla_type) {
+		case HSR_A_NODE_ADDR:
+			if (AddrA)
+				printf("%s: Too many AddrA in message!\n", __func__);
+			AddrA =3D nla_data(attr);
+			break;
+		case HSR_A_NODE_ADDR_B:
+			if (AddrB)
+				printf("%s: Too many AddrB in message!\n", __func__);
+			AddrB =3D nla_data(attr);
+			break;
+		case HSR_A_IFINDEX:
+			break;
+		case HSR_A_IF1_AGE:
+			if1_age =3D (int) nla_get_u32(attr);
+			break;
+		case HSR_A_IF2_AGE:
+			if2_age =3D (int) nla_get_u32(attr);
+			break;
+		case HSR_A_IF1_SEQ:
+			if1_seq =3D nla_get_u16(attr);
+			break;
+		case HSR_A_IF2_SEQ:
+			if2_seq =3D nla_get_u16(attr);
+			break;
+		case HSR_A_IF1_IFINDEX:
+			if1_ifindex =3D nla_get_u32(attr);
+			break;
+		case HSR_A_IF2_IFINDEX:
+			if2_ifindex =3D nla_get_u32(attr);
+			break;
+		case HSR_A_ADDR_B_IFINDEX:
+			addr_b_ifindex =3D nla_get_u32(attr);
+			break;
+		default:
+			printf("%s: unknown attribute type: %d\n", __func__, attr->nla_type=
);
+		}
+		attr =3D nla_next(attr, &remaining);
+	}
+
+	if (!AddrA) {
+		printf("Error: invalid HSR_C_SET_NODE_STATUS packet\n");
+		return;
+	}
+
+	nameptr =3D if_indextoname(if1_ifindex, if1_ifname);
+	if (!nameptr)
+		snprintf(if1_ifname, IF_NAMESIZE, "if%d", if1_ifindex);
+	nameptr =3D if_indextoname(if2_ifindex, if2_ifname);
+	if (!nameptr)
+		snprintf(if2_ifname, IF_NAMESIZE, "if%d", if2_ifindex);
+	nameptr =3D if_indextoname(addr_b_ifindex, addr_b_ifname);
+	if (!nameptr)
+		snprintf(addr_b_ifname, IF_NAMESIZE, "if%d", addr_b_ifindex);
+
+	printf("Node: ");
+	print_mac(AddrA);
+	if (AddrB) {
+		printf("    AddrB: ");
+		print_mac(AddrB);
+		printf(" (over %s)", addr_b_ifname);
+	}
+	printf("\n      Sequence nr (age): %s: %5d (%5d ms); %s: %5d (%5d ms)=
\n",
+		if1_ifname, if1_seq, if1_age,
+		if2_ifname, if2_seq, if2_age);
+}
+
+static void parse_node_list(struct genlmsghdr *hdr)
+{
+	struct nlattr *attr;
+
+	nodelist_clear(&node_head);
+
+	attr =3D genlmsg_attrdata(hdr, 0);
+	int remaining =3D genlmsg_attrlen(hdr, 0);
+	while (nla_ok(attr, remaining)) {
+		switch (attr->nla_type) {
+		case HSR_A_NODE_ADDR:
+			nodelist_add(&node_head, nla_data(attr));
+			break;
+		default:
+			printf("Unknown attribute type for HSR_C_SET_NODE_LIST: %d\n", attr=
->nla_type);
+		}
+		attr =3D nla_next(attr, &remaining);
+	}
+}
+
+
+static int parse_genlmsg(struct nl_msg *msg, void *arg)
+{
+	struct genlmsghdr *hdr;
+
+	/*
+	 * Extract command ID from "message" -> "netlink header" ->
+	 * "generic netlink header".
+	 *
+	 * These are the command enums used when creating a genl msg header
+	 * in the kernel with genlmsg_put().
+	 */
+	hdr =3D genlmsg_hdr(nlmsg_hdr(msg));
+
+//	printf("%d: ", nlmsg_hdr(msg)->nlmsg_seq);
+	switch (hdr->cmd) {
+	case HSR_C_RING_ERROR:
+		parse_ring_error(hdr);
+		break;
+	case HSR_C_NODE_DOWN:
+		parse_node_down(hdr);
+		break;
+	case HSR_C_SET_NODE_STATUS:
+		parse_node_status(hdr);
+		break;
+	case HSR_C_SET_NODE_LIST:
+		parse_node_list(hdr);
+		break;
+	default:
+		printf("Unknown genl message received (%d)\n", hdr->cmd);
+	}
+
+	return 0;
+}
+
+
+static int query_get_node_status(struct nl_sock *nlsk, int family, int=
 ifindex,
+					const unsigned char node_addr[ETH_ALEN])
+{
+	struct nl_msg *msg;
+	void *user_hdr;
+
+	msg =3D nlmsg_alloc();
+	if (!msg)
+		return -1;
+
+	user_hdr =3D genlmsg_put(msg, NL_AUTO_PORT, seq_nr++, family,
+				0, NLM_F_REQUEST, HSR_C_GET_NODE_STATUS, 1);
+	if (!user_hdr)
+		goto nla_put_failure;
+
+	NLA_PUT_U32(msg, HSR_A_IFINDEX, ifindex);
+	NLA_PUT(msg, HSR_A_NODE_ADDR, ETH_ALEN, node_addr);
+
+/*
+	printf("Querying if %d for status of node ", ifindex);
+	print_mac(node_addr);
+	printf("\n");
+*/
+
+	return (nl_send_auto(nlsk, msg));
+
+nla_put_failure:
+	nlmsg_free(msg);
+	return -1;
+}
+
+
+static int query_get_node_list(struct nl_sock *nlsk, int family, int i=
findex)
+{
+	struct nl_msg *msg;
+	void *user_hdr;
+
+	msg =3D nlmsg_alloc();
+	if (!msg)
+		return -1;
+
+	user_hdr =3D genlmsg_put(msg, NL_AUTO_PORT, seq_nr++, family,
+				0, NLM_F_REQUEST, HSR_C_GET_NODE_LIST, 1);
+	if (!user_hdr)
+		goto nla_put_failure;
+
+	NLA_PUT_U32(msg, HSR_A_IFINDEX, ifindex);
+
+//	printf("Querying if %d for node list\n", ifindex);
+
+	return (nl_send_auto(nlsk, msg));
+
+nla_put_failure:
+	nlmsg_free(msg);
+	return -1;
+}
+
+
+
+static void print_usage(const char *name)
+{
+	printf(
+"Usage: %s [-q] interface [node mac address]\n"
+"Display ring error messages for a HSR network interface, or\n"
+"(-q) query the interface node database. The node address parameter is=
 only\n"
+"valid with -q, and limits the output to data about a specific node.\n=
", name);
+}
+
+
+static const char optstring[] =3D "+q";
+
+int main(int argc, char **argv)
+{
+	struct nl_sock *nlsk;
+	int hsr_mgroup;
+	int query;
+	int opt, rc;
+	int hsr_ifindex;
+	struct node_item *ni;
+
+	query =3D 0;
+	opt =3D getopt(argc, argv, optstring);
+	while (opt !=3D -1) {
+		switch (opt) {
+		case 'q':
+			query =3D 1;
+			break;
+		default:
+			print_usage(argv[0]);
+			return EXIT_FAILURE;
+		}
+		opt =3D getopt(argc, argv, optstring);
+	}
+
+
+	nlsk =3D nl_socket_alloc();
+	if (!nlsk) {
+		printf("nl_socket_alloc() failed\n");
+		return EXIT_FAILURE;
+	}
+	nl_socket_modify_cb(nlsk, NL_CB_VALID, NL_CB_CUSTOM, parse_genlmsg, N=
ULL);
+	genl_connect(nlsk);
+
+	/*
+	 * Sign up for HSR messages
+	 */
+	hsr_mgroup =3D genl_ctrl_resolve_grp(nlsk, "HSR", "hsr-network");
+	if (hsr_mgroup < 0) {
+		printf("genl_ctrl_resolve_grp() failed: %d\n", hsr_mgroup);
+		rc =3D EXIT_FAILURE;
+		goto out;
+	}
+
+	nl_socket_disable_seq_check(nlsk);
+
+	if (!query) {
+		if (argc - optind !=3D 1) {
+			print_usage(argv[0]);
+			return EXIT_FAILURE;
+		}
+
+//		printf("Registering for multicast group %d\n", hsr_mgroup);
+		rc =3D nl_socket_add_memberships(nlsk, hsr_mgroup, 0);
+		if (rc < 0) {
+			printf("nl_socket_add_memberships() failed: %d\n", rc);
+			goto out;
+		}
+
+		while (1)
+			nl_recvmsgs_default(nlsk);
+
+		/* Not reached */
+	}
+
+
+	if (argc - optind < 1) {
+		print_usage(argv[0]);
+		return EXIT_FAILURE;
+	}
+
+	/* The hsr if we send the enquiry to (get it with e.g.
+	 * 'cat /sys/class/net/hsr0/ifindex'): */
+	hsr_ifindex =3D if_nametoindex(argv[optind]);
+	if (hsr_ifindex =3D=3D 0) {
+		printf("%s: %s\n", argv[optind], strerror(errno));
+		exit(EXIT_FAILURE);
+	}
+
+	/* Get node list */
+	int hsr_family;
+
+	hsr_family =3D genl_ctrl_resolve(nlsk, "HSR");
+	if (hsr_family < 0) {
+		printf("genl_ctrl_resolve() failed: %d\n", hsr_family);
+		goto out;
+	}
+
+	rc =3D query_get_node_list(nlsk, hsr_family, hsr_ifindex);
+//	printf("query_get_node_list() returned %d\n", rc);
+
+	rc =3D nl_recvmsgs_default(nlsk);
+//	printf("nl_recvmsgs_default() returned %d\n", rc);
+
+	ni =3D node_head;
+	while (ni) {
+		/*
+		 * Send a query about the status of another node on the HSR network:
+		 */
+		/* The node to enquire about: */
+		//const unsigned char node[ETH_ALEN] =3D {0x00, 0x24, 0x74, 0x00, 0x=
17, 0xAD};
+
+		rc =3D query_get_node_status(nlsk, hsr_family, hsr_ifindex, ni->addr=
);
+//		printf("query_node_status() returned %d\n", rc);
+
+		ni =3D ni->next;
+	}
+
+	while (1) {
+		rc =3D nl_recvmsgs_default(nlsk);
+//		printf("nl_recvmsgs_default() returned %d\n", rc);
+	}
+
+
+	rc =3D EXIT_SUCCESS;
+out:
+	nl_close(nlsk);
+	nl_socket_free(nlsk);
+	return rc;
+}


--=20
Arvid Brodin | Consultant (Linux)
XDIN AB | Knarrarn=E4sgatan 7 | SE-164 40 Kista | Sweden | xdin.com
