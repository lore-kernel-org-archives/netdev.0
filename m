From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 4/4] samples/bpf: export map_data[] for more info
 on maps
Date: Tue, 02 May 2017 14:32:06 +0200
Message-ID: <149372832617.22268.13214976764737514956.stgit@firesoul>
References: <149372826543.22268.3617359219409721129.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric@regit.org,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27527 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751443AbdEBMcS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 2 May 2017 08:32:18 -0400
In-Reply-To: <149372826543.22268.3617359219409721129.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Giving *_user.c side tools access to map_data[] provides easier
access to information on the maps being loaded.  Still provide
the guarantee that the order maps are being defined in inside the
_kern.c file corresponds with the order in the array.  Now user
tools are not blind, but can inspect and verify the maps that got
loaded from the ELF binary.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 samples/bpf/bpf_load.h |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/samples/bpf/bpf_load.h b/samples/bpf/bpf_load.h
index 4d4fd4678a64..ca0563d04744 100644
--- a/samples/bpf/bpf_load.h
+++ b/samples/bpf/bpf_load.h
@@ -24,12 +24,18 @@ struct bpf_map_data {
 
 typedef void (*fixup_map_cb)(struct bpf_map_data *map, int idx);
 
-extern int map_fd[MAX_MAPS];
 extern int prog_fd[MAX_PROGS];
 extern int event_fd[MAX_PROGS];
 extern char bpf_log_buf[BPF_LOG_BUF_SIZE];
 extern int prog_cnt;
 
+/* There is a one-to-one mapping between map_fd[] and map_data[].
+ * The map_data[] just contains more rich info on the given map.
+ */
+extern int map_fd[MAX_MAPS];
+extern struct bpf_map_data map_data[MAX_MAPS];
+extern int map_data_count;
+
 /* parses elf file compiled by llvm .c->.o
  * . parses 'maps' section and creates maps via BPF syscall
  * . parses 'license' section and passes it to syscall
