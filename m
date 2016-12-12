From: David Ahern <dsa@cumulusnetworks.com>
Subject: [iproute2 net-next 1/8] lib bpf: Add support for BPF_PROG_ATTACH and BPF_PROG_DETACH
Date: Sun, 11 Dec 2016 16:53:08 -0800
Message-ID: <1481503995-24825-2-git-send-email-dsa@cumulusnetworks.com>
References: <1481503995-24825-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:36769 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752696AbcLLAxX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Dec 2016 19:53:23 -0500
Received: by mail-pg0-f51.google.com with SMTP id f188so28946287pgc.3
        for <netdev@vger.kernel.org>; Sun, 11 Dec 2016 16:53:23 -0800 (PST)
In-Reply-To: <1481503995-24825-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/bpf_util.h |  3 +++
 lib/bpf.c          | 21 +++++++++++++++++++++
 2 files changed, 24 insertions(+)

diff --git a/include/bpf_util.h b/include/bpf_util.h
index 05baeecda57f..b038379684a8 100644
--- a/include/bpf_util.h
+++ b/include/bpf_util.h
@@ -75,6 +75,9 @@ int bpf_trace_pipe(void);
 
 void bpf_print_ops(FILE *f, struct rtattr *bpf_ops, __u16 len);
 
+int bpf_prog_attach_fd(int prog_fd, int target_fd, enum bpf_attach_type type);
+int bpf_prog_detach_fd(int target_fd, enum bpf_attach_type type);
+
 #ifdef HAVE_ELF
 int bpf_send_map_fds(const char *path, const char *obj);
 int bpf_recv_map_fds(const char *path, int *fds, struct bpf_map_aux *aux,
diff --git a/lib/bpf.c b/lib/bpf.c
index 2a8cd51d4dae..5d6dcaa949de 100644
--- a/lib/bpf.c
+++ b/lib/bpf.c
@@ -850,6 +850,27 @@ int bpf_graft_map(const char *map_path, uint32_t *key, int argc, char **argv)
 	return ret;
 }
 
+int bpf_prog_attach_fd(int prog_fd, int target_fd, enum bpf_attach_type type)
+{
+	union bpf_attr attr = {};
+
+	attr.target_fd = target_fd;
+	attr.attach_bpf_fd = prog_fd;
+	attr.attach_type = type;
+
+	return bpf(BPF_PROG_ATTACH, &attr, sizeof(attr));
+}
+
+int bpf_prog_detach_fd(int target_fd, enum bpf_attach_type type)
+{
+	union bpf_attr attr = {};
+
+	attr.target_fd = target_fd;
+	attr.attach_type = type;
+
+	return bpf(BPF_PROG_DETACH, &attr, sizeof(attr));
+}
+
 #ifdef HAVE_ELF
 struct bpf_elf_prog {
 	enum bpf_prog_type	type;
-- 
2.1.4
