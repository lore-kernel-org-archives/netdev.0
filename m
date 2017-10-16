From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 1/3] bpf: Don't check for current being NULL
Date: Mon, 16 Oct 2017 20:18:54 +0200
Message-ID: <20171016181856.12497-1-richard@nod.at>
Cc: linux-kernel@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org,
        Richard Weinberger <richard@nod.at>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

current is never NULL.

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 kernel/bpf/helpers.c | 12 ------------
 1 file changed, 12 deletions(-)

diff --git a/kernel/bpf/helpers.c b/kernel/bpf/helpers.c
index 3d24e238221e..e8845adcd15e 100644
--- a/kernel/bpf/helpers.c
+++ b/kernel/bpf/helpers.c
@@ -120,9 +120,6 @@ BPF_CALL_0(bpf_get_current_pid_tgid)
 {
 	struct task_struct *task = current;
 
-	if (unlikely(!task))
-		return -EINVAL;
-
 	return (u64) task->tgid << 32 | task->pid;
 }
 
@@ -138,9 +135,6 @@ BPF_CALL_0(bpf_get_current_uid_gid)
 	kuid_t uid;
 	kgid_t gid;
 
-	if (unlikely(!task))
-		return -EINVAL;
-
 	current_uid_gid(&uid, &gid);
 	return (u64) from_kgid(&init_user_ns, gid) << 32 |
 		     from_kuid(&init_user_ns, uid);
@@ -156,9 +150,6 @@ BPF_CALL_2(bpf_get_current_comm, char *, buf, u32, size)
 {
 	struct task_struct *task = current;
 
-	if (unlikely(!task))
-		goto err_clear;
-
 	strncpy(buf, task->comm, size);
 
 	/* Verifier guarantees that size > 0. For task->comm exceeding
@@ -167,9 +158,6 @@ BPF_CALL_2(bpf_get_current_comm, char *, buf, u32, size)
 	 */
 	buf[size - 1] = 0;
 	return 0;
-err_clear:
-	memset(buf, 0, size);
-	return -EINVAL;
 }
 
 const struct bpf_func_proto bpf_get_current_comm_proto = {
-- 
2.13.6
