From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH] cgroup: Fix CGROUP_BPF config
Date: Fri, 16 Dec 2016 08:33:45 -0800
Message-ID: <8d48c3940f8d0275da6398ea5bcef14e20233db5.1481905995.git.luto@kernel.org>
Cc: Network Development <netdev@vger.kernel.org>,
        Andy Lutomirski <luto@kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:51594 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755562AbcLPQds (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Dec 2016 11:33:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CGROUP_BPF depended on SOCK_CGROUP_DATA which can't be manually
enabled, making it rather challenging to turn CGROUP_BPF on.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 init/Kconfig | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/init/Kconfig b/init/Kconfig
index aafafeb0c117..223b734abccd 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1156,7 +1156,8 @@ config CGROUP_PERF
 
 config CGROUP_BPF
 	bool "Support for eBPF programs attached to cgroups"
-	depends on BPF_SYSCALL && SOCK_CGROUP_DATA
+	depends on BPF_SYSCALL
+	select SOCK_CGROUP_DATA
 	help
 	  Allow attaching eBPF programs to a cgroup using the bpf(2)
 	  syscall command BPF_PROG_ATTACH.
-- 
2.9.3
