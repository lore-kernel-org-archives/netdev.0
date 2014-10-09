From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net] net: bpf: fix bpf syscall dependence on anon_inodes
Date: Thu,  9 Oct 2014 15:16:41 -0700
Message-ID: <1412893001-8401-1-git-send-email-ast@plumgrid.com>
Cc: Michal Sojka <sojkam1@fel.cvut.cz>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

minimal configurations where EPOLL, PERF_EVENTS, etc are disabled,
but NET is enabled, are failing to build with link error:
kernel/built-in.o: In function `bpf_prog_load':
syscall.c:(.text+0x3b728): undefined reference to `anon_inode_getfd'

fix it by selecting ANON_INODES when NET is enabled

Reported-by: Michal Sojka <sojkam1@fel.cvut.cz>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---

I understand that 'select' is highly non-recommended for all good reasons,
but here 'depends on' is very user unfriendly, since ANON_INODES is
a hidden config that users cannot select directly.

 net/Kconfig |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/Kconfig b/net/Kconfig
index d6b138e..6272420 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -6,6 +6,7 @@ menuconfig NET
 	bool "Networking support"
 	select NLATTR
 	select GENERIC_NET_UTILS
+	select ANON_INODES
 	---help---
 	  Unless you really know what you are doing, you should say Y here.
 	  The reason is that some programs need kernel networking support even
-- 
1.7.9.5
