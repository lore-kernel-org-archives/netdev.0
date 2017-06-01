From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Subject: [PATCH net-next v2] bpf: Remove the capability check for cgroup skb eBPF program
Date: Wed, 31 May 2017 18:12:20 -0700
Message-ID: <1496279540-20812-1-git-send-email-chenbofeng.kernel@gmail.com>
Cc: Lorenzo Colitti <lorenzo@google.com>,
        Chenbo Feng <fengc@google.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36065 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750954AbdFABMc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 21:12:32 -0400
Received: by mail-pf0-f195.google.com with SMTP id n23so5257541pfb.3
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 18:12:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chenbo Feng <fengc@google.com>

Currently loading a cgroup skb eBPF program require a CAP_SYS_ADMIN
capability while attaching the program to a cgroup only requires the
user have CAP_NET_ADMIN privilege. We can escape the capability
check when load the program just like socket filter program to make
the capability requirement consistent.

Change since v1:
Change the code style in order to be compliant with checkpatch.pl
preference

Signed-off-by: Chenbo Feng <fengc@google.com>
---
 kernel/bpf/syscall.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 265a0d8..59da103 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -815,7 +815,9 @@ static int bpf_prog_load(union bpf_attr *attr)
 	    attr->kern_version != LINUX_VERSION_CODE)
 		return -EINVAL;
 
-	if (type != BPF_PROG_TYPE_SOCKET_FILTER && !capable(CAP_SYS_ADMIN))
+	if (type != BPF_PROG_TYPE_SOCKET_FILTER &&
+	    type != BPF_PROG_TYPE_CGROUP_SKB &&
+	    !capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
 	/* plain bpf_prog allocation */
-- 
2.7.4
