From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH -next] bpf: make inode code explicitly non-modular
Date: Mon, 11 Jul 2016 12:51:01 -0400
Message-ID: <20160711165101.2252-1-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	Alexei Starovoitov <ast@kernel.org>, <netdev@vger.kernel.org>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Kconfig currently controlling compilation of this code is:

init/Kconfig:config BPF_SYSCALL
init/Kconfig:   bool "Enable bpf() system call"

...meaning that it currently is not being built as a module by anyone.

Lets remove the couple traces of modular infrastructure use, so that
when reading the driver there is no doubt it is builtin-only.

Note that MODULE_ALIAS is a no-op for non-modular code.

We replace module.h with init.h since the file does use __init.

Cc: Alexei Starovoitov <ast@kernel.org>
Cc: netdev@vger.kernel.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 kernel/bpf/inode.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/kernel/bpf/inode.c b/kernel/bpf/inode.c
index 318858edb1cd..5967b870a895 100644
--- a/kernel/bpf/inode.c
+++ b/kernel/bpf/inode.c
@@ -11,7 +11,7 @@
  * version 2 as published by the Free Software Foundation.
  */
 
-#include <linux/module.h>
+#include <linux/init.h>
 #include <linux/magic.h>
 #include <linux/major.h>
 #include <linux/mount.h>
@@ -367,8 +367,6 @@ static struct file_system_type bpf_fs_type = {
 	.kill_sb	= kill_litter_super,
 };
 
-MODULE_ALIAS_FS("bpf");
-
 static int __init bpf_init(void)
 {
 	int ret;
-- 
2.8.4
