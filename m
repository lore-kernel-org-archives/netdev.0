From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next] security: bpf: replace include of linux/bpf.h with forward declarations
Date: Wed,  1 Nov 2017 11:48:00 -0700
Message-ID: <20171101184800.16416-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, Chenbo Feng <fengc@google.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:50645 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753080AbdKASsH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 14:48:07 -0400
Received: by mail-pf0-f193.google.com with SMTP id b6so2617217pfh.7
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 11:48:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Touching linux/bpf.h makes us rebuild a surprisingly large
portion of the kernel.  Remove the unnecessary dependency
from security.h, it only needs forward declarations.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Quentin Monnet <quentin.monnet@netronome.com>
---
 include/linux/security.h | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/linux/security.h b/include/linux/security.h
index 18800b0911e5..73f1ef625d40 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -31,7 +31,6 @@
 #include <linux/string.h>
 #include <linux/mm.h>
 #include <linux/fs.h>
-#include <linux/bpf.h>
 
 struct linux_binprm;
 struct cred;
@@ -1732,6 +1731,10 @@ static inline void securityfs_remove(struct dentry *dentry)
 #endif
 
 #ifdef CONFIG_BPF_SYSCALL
+union bpf_attr;
+struct bpf_map;
+struct bpf_prog;
+struct bpf_prog_aux;
 #ifdef CONFIG_SECURITY
 extern int security_bpf(int cmd, union bpf_attr *attr, unsigned int size);
 extern int security_bpf_map(struct bpf_map *map, fmode_t fmode);
-- 
2.14.1
