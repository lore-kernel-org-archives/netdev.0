From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 2/3] bpf: Use char in prog and map name
Date: Thu, 5 Oct 2017 21:52:12 -0700
Message-ID: <20171006045213.752372-3-kafai@fb.com>
References: <20171006045213.752372-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:44048 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750863AbdJFEwT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 00:52:19 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v964o7n9021771
        for <netdev@vger.kernel.org>; Thu, 5 Oct 2017 21:52:19 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2ddxebh5he-5
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 21:52:19 -0700
In-Reply-To: <20171006045213.752372-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of u8, use char for prog and map name.  It can avoid the
userspace tool getting compiler's signess warning.  The
bpf_prog_aux, bpf_map, bpf_attr, bpf_prog_info and
bpf_map_info are changed.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@fb.com>
---
 include/linux/bpf.h            | 4 ++--
 include/uapi/linux/bpf.h       | 8 ++++----
 tools/include/uapi/linux/bpf.h | 8 ++++----
 3 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index a67daea731ab..bc7da2ddfcaf 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -56,7 +56,7 @@ struct bpf_map {
 	struct work_struct work;
 	atomic_t usercnt;
 	struct bpf_map *inner_map_meta;
-	u8 name[BPF_OBJ_NAME_LEN];
+	char name[BPF_OBJ_NAME_LEN];
 };
 
 /* function argument constraints */
@@ -189,7 +189,7 @@ struct bpf_prog_aux {
 	struct bpf_prog *prog;
 	struct user_struct *user;
 	u64 load_time; /* ns since boottime */
-	u8 name[BPF_OBJ_NAME_LEN];
+	char name[BPF_OBJ_NAME_LEN];
 	union {
 		struct work_struct work;
 		struct rcu_head	rcu;
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 6082faf5fd2a..a37ad348c436 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -230,7 +230,7 @@ union bpf_attr {
 		__u32	numa_node;	/* numa node (effective only if
 					 * BPF_F_NUMA_NODE is set).
 					 */
-		__u8	map_name[BPF_OBJ_NAME_LEN];
+		char	map_name[BPF_OBJ_NAME_LEN];
 	};
 
 	struct { /* anonymous struct used by BPF_MAP_*_ELEM commands */
@@ -253,7 +253,7 @@ union bpf_attr {
 		__aligned_u64	log_buf;	/* user supplied buffer */
 		__u32		kern_version;	/* checked when prog_type=kprobe */
 		__u32		prog_flags;
-		__u8		prog_name[BPF_OBJ_NAME_LEN];
+		char		prog_name[BPF_OBJ_NAME_LEN];
 	};
 
 	struct { /* anonymous struct used by BPF_OBJ_* commands */
@@ -869,7 +869,7 @@ struct bpf_prog_info {
 	__u32 created_by_uid;
 	__u32 nr_map_ids;
 	__aligned_u64 map_ids;
-	__u8  name[BPF_OBJ_NAME_LEN];
+	char name[BPF_OBJ_NAME_LEN];
 } __attribute__((aligned(8)));
 
 struct bpf_map_info {
@@ -879,7 +879,7 @@ struct bpf_map_info {
 	__u32 value_size;
 	__u32 max_entries;
 	__u32 map_flags;
-	__u8  name[BPF_OBJ_NAME_LEN];
+	char  name[BPF_OBJ_NAME_LEN];
 } __attribute__((aligned(8)));
 
 /* User bpf_sock_ops struct to access socket values and specify request ops
diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index cb2b9f95160a..f75ac330831d 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -230,7 +230,7 @@ union bpf_attr {
 		__u32	numa_node;	/* numa node (effective only if
 					 * BPF_F_NUMA_NODE is set).
 					 */
-		__u8	map_name[BPF_OBJ_NAME_LEN];
+		char	map_name[BPF_OBJ_NAME_LEN];
 	};
 
 	struct { /* anonymous struct used by BPF_MAP_*_ELEM commands */
@@ -253,7 +253,7 @@ union bpf_attr {
 		__aligned_u64	log_buf;	/* user supplied buffer */
 		__u32		kern_version;	/* checked when prog_type=kprobe */
 		__u32		prog_flags;
-		__u8		prog_name[BPF_OBJ_NAME_LEN];
+		char		prog_name[BPF_OBJ_NAME_LEN];
 	};
 
 	struct { /* anonymous struct used by BPF_OBJ_* commands */
@@ -869,7 +869,7 @@ struct bpf_prog_info {
 	__u32 created_by_uid;
 	__u32 nr_map_ids;
 	__aligned_u64 map_ids;
-	__u8  name[BPF_OBJ_NAME_LEN];
+	char  name[BPF_OBJ_NAME_LEN];
 } __attribute__((aligned(8)));
 
 struct bpf_map_info {
@@ -879,7 +879,7 @@ struct bpf_map_info {
 	__u32 value_size;
 	__u32 max_entries;
 	__u32 map_flags;
-	__u8  name[BPF_OBJ_NAME_LEN];
+	char  name[BPF_OBJ_NAME_LEN];
 } __attribute__((aligned(8)));
 
 /* User bpf_sock_ops struct to access socket values and specify request ops
-- 
2.9.5
