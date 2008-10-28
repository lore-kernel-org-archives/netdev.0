From: Vivien Chappelier <vivien.chappelier@thomson.net>
Subject: [PATCH 0/6] netns: port linux-vrf features to network namespaces
Date: Tue, 28 Oct 2008 18:35:56 +0100
Message-ID: <49074D7C.7010505@thomson.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050007010004080607040101"
Cc: David Miller <davem@davemloft.net>,
	Benjamin Thery <benjamin.thery@bull.net>, jleu@mindspring.com,
	linux-vrf-general@lists.sourceforge.net
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.thmulti.com ([141.11.234.72]:33861 "EHLO
	dmzraw4.extranet.thmulti.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752149AbYJ1R6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 13:58:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050007010004080607040101
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

    The recently introduced network namespaces allow separate standalone 
network stacks to coexist on the same machine. This is a very useful 
functionality that we have been using in our products for some time, 
through the VRF patchset (http://linux-vrf.sourceforge.net/). The goal 
of the VRF patchset and network namespaces are very similar, yet some 
features of the VRF are missing that these patches intend to provide.

    The network namespaces are currently tied to a process, and 
referenced by its pid. However, a networking stack has no particular 
reason to be associated with any process and it should be possible to 
use and setup additional networking stacks without the need to clone() 
or unshare(). The initial version of the "Coexist with the sysfs 
limitations" patches by Benjamin Thery introduced the notion of a unique 
network namespace identifier (nsid)  that is perfectly fit for the 
purpose of referencing networking stacks independently of any process. 
The first two patches of his set are therefore reused here to identify 
networking stacks.

    These patches additionally introduce the following features that 
were initially provided by the VRF patchset:
- the ability to move a socket to a different network namespace, through 
the new SO_NSID setsockopt(), given the nsid
- the ability to move a process to an existing network namespace, 
through the new SO_NETNS setsockopt(), given the nsid
- the ability to move an interface to a different namespace by nsid 
instead of pid
- the ability to create additional network namespaces on startup 
(dynamic addition/deletion is not supported but should be easy to add)

   To test those features, the chvrf tools attached in this mail have 
been ported to the new setsockopt() API. Example usage:

$ chnetns 1 /bin/sh   # This will attach a shell to existing network 
namespace 1

$ port -n 1 -p 3434   # This will open a listening socket on port 3434 
of network namespace 1

   Also attached is a patch to iproute2 to add the ability to move an 
interface to a different namespace by nsid, used this way:

$ ip link set eth0 nsid 1    # This will move eth0 to network namespace 1

   The patches should apply cleanly to the net-next-2.6 git tree, 
version 2.6.28-rc2, at commit 3891845e1ef6e6807075d4241966b26f6ecb0a5c.

   I would be glad to have your impression and comments on these 
patches, and to have them merged upstream once everybody is satisfied 
with them.

regards,
Vivien Chappelier.


--------------050007010004080607040101
Content-Type: application/x-gzip;
 name="chnetns.tar.gz"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="chnetns.tar.gz"

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
--------------050007010004080607040101
Content-Type: text/x-diff;
 name="iproute2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="iproute2.patch"

>From 698eb7aeb60baca7fc7f0fda9080174c96f92e02 Mon Sep 17 00:00:00 2001
From: Vivien Chappelier <vivien.chappelier@thomson.net>
Date: Tue, 28 Oct 2008 18:06:13 +0100
Subject: [PATCH] Add support for testing IFLA_NET_NS

---
 include/linux/if_link.h |    2 ++
 ip/iplink.c             |    9 +++++++++
 misc/Makefile           |    2 +-
 3 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index c948395..fab393d 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -79,6 +79,8 @@ enum
 	IFLA_LINKINFO,
 #define IFLA_LINKINFO IFLA_LINKINFO
 	IFLA_NET_NS_PID,
+	IFLA_IFALIAS,
+	IFLA_NET_NS,
 	__IFLA_MAX
 };
 
diff --git a/ip/iplink.c b/ip/iplink.c
index fd23db1..ffb0d39 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -67,6 +67,7 @@ void iplink_usage(void)
 	fprintf(stderr, "	                  [ broadcast LLADDR ]\n");
 	fprintf(stderr, "	                  [ mtu MTU ]\n");
 	fprintf(stderr, "	                  [ netns PID ]\n");
+	fprintf(stderr, "	                  [ nsid NSID ]\n");
 	fprintf(stderr, "       ip link show [ DEVICE ]\n");
 
 	if (iplink_have_newlink()) {
@@ -179,6 +180,7 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 	char abuf[32];
 	int qlen = -1;
 	int mtu = -1;
+	int net = -1;
 	int netns = -1;
 
 	ret = argc;
@@ -228,6 +230,13 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
                         if (get_integer(&netns, *argv, 0))
                                 invarg("Invalid \"netns\" value\n", *argv);
                         addattr_l(&req->n, sizeof(*req), IFLA_NET_NS_PID, &netns, 4);
+		} else if (strcmp(*argv, "nsid") == 0) {
+                        NEXT_ARG();
+                        if (net != -1)
+                                duparg("nsid", *argv);
+                        if (get_integer(&net, *argv, 0))
+                                invarg("Invalid \"nsid\" value\n", *argv);
+                        addattr_l(&req->n, sizeof(*req), IFLA_NET_NS, &net, 4);
 		} else if (strcmp(*argv, "multicast") == 0) {
 			NEXT_ARG();
 			req->i.ifi_change |= IFF_MULTICAST;
diff --git a/misc/Makefile b/misc/Makefile
index 8c25381..a4c9591 100644
--- a/misc/Makefile
+++ b/misc/Makefile
@@ -1,7 +1,7 @@
 SSOBJ=ss.o ssfilter.o
 LNSTATOBJ=lnstat.o lnstat_util.o
 
-TARGETS=ss nstat ifstat rtacct arpd lnstat
+TARGETS=ss nstat ifstat rtacct lnstat
 
 include ../Config
 
-- 
1.5.4.4


--------------050007010004080607040101--
