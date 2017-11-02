From: Prashant Bhole <bhole_prashant_q7@lab.ntt.co.jp>
Subject: [PATCH net-next V2 1/3] tools: bpftool: open pinned object without type check
Date: Thu,  2 Nov 2017 16:59:15 +0900
Message-ID: <20171102075917.2780-2-bhole_prashant_q7@lab.ntt.co.jp>
References: <20171102075917.2780-1-bhole_prashant_q7@lab.ntt.co.jp>
Cc: Prashant Bhole <bhole_prashant_q7@lab.ntt.co.jp>,
        netdev@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Quentin Monnet <quentin.monnet@netronome.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:33062 "EHLO
        tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755601AbdKBIBM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 04:01:12 -0400
In-Reply-To: <20171102075917.2780-1-bhole_prashant_q7@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was needed for opening any file in bpf-fs without knowing
its object type

Signed-off-by: Prashant Bhole <bhole_prashant_q7@lab.ntt.co.jp>
---
 tools/bpf/bpftool/common.c | 15 +++++++++++++--
 tools/bpf/bpftool/main.h   |  1 +
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/tools/bpf/bpftool/common.c b/tools/bpf/bpftool/common.c
index f0288269dae8..4556947709ee 100644
--- a/tools/bpf/bpftool/common.c
+++ b/tools/bpf/bpftool/common.c
@@ -91,9 +91,8 @@ static int mnt_bpffs(const char *target, char *buff, size_t bufflen)
 	return 0;
 }
 
-int open_obj_pinned_any(char *path, enum bpf_obj_type exp_type)
+int open_obj_pinned(char *path)
 {
-	enum bpf_obj_type type;
 	int fd;
 
 	fd = bpf_obj_get(path);
@@ -105,6 +104,18 @@ int open_obj_pinned_any(char *path, enum bpf_obj_type exp_type)
 		return -1;
 	}
 
+	return fd;
+}
+
+int open_obj_pinned_any(char *path, enum bpf_obj_type exp_type)
+{
+	enum bpf_obj_type type;
+	int fd;
+
+	fd = open_obj_pinned(path);
+	if (fd < 0)
+		return -1;
+
 	type = get_fd_type(fd);
 	if (type < 0) {
 		close(fd);
diff --git a/tools/bpf/bpftool/main.h b/tools/bpf/bpftool/main.h
index d315d01be645..4b5685005cb0 100644
--- a/tools/bpf/bpftool/main.h
+++ b/tools/bpf/bpftool/main.h
@@ -86,6 +86,7 @@ int cmd_select(const struct cmd *cmds, int argc, char **argv,
 int get_fd_type(int fd);
 const char *get_fd_type_name(enum bpf_obj_type type);
 char *get_fdinfo(int fd, const char *key);
+int open_obj_pinned(char *path);
 int open_obj_pinned_any(char *path, enum bpf_obj_type exp_type);
 int do_pin_any(int argc, char **argv, int (*get_fd_by_id)(__u32));
 
-- 
2.13.6
