From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 2/6] Convert the obvious cases to strlcpy()
Date: Fri,  1 Sep 2017 18:52:52 +0200
Message-ID: <20170901165256.21459-3-phil@nwl.cc>
References: <20170901165256.21459-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:47059 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752148AbdIAQx1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 12:53:27 -0400
In-Reply-To: <20170901165256.21459-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This converts the typical idiom of manually terminating the buffer after
a call to strncpy().

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipnetns.c          | 3 +--
 ip/iproute_lwtunnel.c | 3 +--
 ip/ipvrf.c            | 3 +--
 lib/bpf.c             | 3 +--
 lib/fs.c              | 3 +--
 lib/inet_proto.c      | 3 +--
 misc/ss.c             | 3 +--
 tc/em_ipset.c         | 3 +--
 8 files changed, 8 insertions(+), 16 deletions(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 9ee1fe6a51f9c..afb4978a5be7d 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -518,8 +518,7 @@ int netns_identify_pid(const char *pidstr, char *name, int len)
 
 		if ((st.st_dev == netst.st_dev) &&
 		    (st.st_ino == netst.st_ino)) {
-			strncpy(name, entry->d_name, len - 1);
-			name[len - 1] = '\0';
+			strlcpy(name, entry->d_name, len);
 		}
 	}
 	closedir(dir);
diff --git a/ip/iproute_lwtunnel.c b/ip/iproute_lwtunnel.c
index 1a3dc4d4c0ed9..4c2d3b07e3b5c 100644
--- a/ip/iproute_lwtunnel.c
+++ b/ip/iproute_lwtunnel.c
@@ -325,8 +325,7 @@ static int parse_encap_seg6(struct rtattr *rta, size_t len, int *argcp,
 				invarg("\"segs\" provided before \"mode\"\n",
 				       *argv);
 
-			strncpy(segbuf, *argv, 1024);
-			segbuf[1023] = 0;
+			strlcpy(segbuf, *argv, 1024);
 		} else if (strcmp(*argv, "hmac") == 0) {
 			NEXT_ARG();
 			if (hmac_ok++)
diff --git a/ip/ipvrf.c b/ip/ipvrf.c
index e6fad32abd956..b74c501e0970c 100644
--- a/ip/ipvrf.c
+++ b/ip/ipvrf.c
@@ -336,8 +336,7 @@ static int vrf_path(char *vpath, size_t len)
 		if (vrf)
 			*vrf = '\0';
 
-		strncpy(vpath, start, len - 1);
-		vpath[len - 1] = '\0';
+		strlcpy(vpath, start, len);
 
 		/* if vrf path is just / then return nothing */
 		if (!strcmp(vpath, "/"))
diff --git a/lib/bpf.c b/lib/bpf.c
index 0bd0a95eafe6c..c180934acc7dc 100644
--- a/lib/bpf.c
+++ b/lib/bpf.c
@@ -512,8 +512,7 @@ static const char *bpf_find_mntpt_single(unsigned long magic, char *mnt,
 
 	ret = bpf_valid_mntpt(mntpt, magic);
 	if (!ret) {
-		strncpy(mnt, mntpt, len - 1);
-		mnt[len - 1] = 0;
+		strlcpy(mnt, mntpt, len);
 		return mnt;
 	}
 
diff --git a/lib/fs.c b/lib/fs.c
index ebe05cd44e11b..86efd4ed2ed80 100644
--- a/lib/fs.c
+++ b/lib/fs.c
@@ -172,8 +172,7 @@ int get_command_name(const char *pid, char *comm, size_t len)
 		if (nl)
 			*nl = '\0';
 
-		strncpy(comm, name, len - 1);
-		comm[len - 1] = '\0';
+		strlcpy(comm, name, len);
 		break;
 	}
 
diff --git a/lib/inet_proto.c b/lib/inet_proto.c
index 53c029039b6d5..bdfd52fdafe5a 100644
--- a/lib/inet_proto.c
+++ b/lib/inet_proto.c
@@ -38,8 +38,7 @@ const char *inet_proto_n2a(int proto, char *buf, int len)
 			free(ncache);
 		icache = proto;
 		ncache = strdup(pe->p_name);
-		strncpy(buf, pe->p_name, len - 1);
-		buf[len - 1] = '\0';
+		strlcpy(buf, pe->p_name, len);
 		return buf;
 	}
 	snprintf(buf, len, "ipproto-%d", proto);
diff --git a/misc/ss.c b/misc/ss.c
index 2c9e80e696595..dd8dfaa4e70db 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -425,8 +425,7 @@ static void user_ent_hash_build(void)
 
 	user_ent_hash_build_init = 1;
 
-	strncpy(name, root, sizeof(name)-1);
-	name[sizeof(name)-1] = 0;
+	strlcpy(name, root, sizeof(name));
 
 	if (strlen(name) == 0 || name[strlen(name)-1] != '/')
 		strcat(name, "/");
diff --git a/tc/em_ipset.c b/tc/em_ipset.c
index b59756515d239..48b287f5ba3b2 100644
--- a/tc/em_ipset.c
+++ b/tc/em_ipset.c
@@ -145,8 +145,7 @@ get_set_byname(const char *setname, struct xt_set_info *info)
 	int res;
 
 	req.op = IP_SET_OP_GET_BYNAME;
-	strncpy(req.set.name, setname, IPSET_MAXNAMELEN);
-	req.set.name[IPSET_MAXNAMELEN - 1] = '\0';
+	strlcpy(req.set.name, setname, IPSET_MAXNAMELEN);
 	res = do_getsockopt(&req);
 	if (res != 0)
 		return -1;
-- 
2.13.1
