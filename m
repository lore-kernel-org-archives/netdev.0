From: Eric Leblond <eric@regit.org>
Subject: [PATCH 3/8] tools: Sync tools/include/uapi/linux/bpf.h with the kernel
Date: Sun, 16 Oct 2016 23:18:29 +0200
Message-ID: <20161016211834.11732-4-eric@regit.org>
References: <20161016211834.11732-1-eric@regit.org>
Cc: linux-kernel@vger.kernel.org, ast@fb.com,
        Eric Leblond <eric@regit.org>
To: netdev@vger.kernel.org, wangnan0@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from home.regit.org ([37.187.126.138]:45257 "EHLO home.regit.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757135AbcJPVVQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 16 Oct 2016 17:21:16 -0400
In-Reply-To: <20161016211834.11732-1-eric@regit.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Leblond <eric@regit.org>
---
 tools/include/uapi/linux/bpf.h | 52 ++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 52 insertions(+)

diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index 9e5fc16..570287f 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -95,6 +95,8 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_SCHED_ACT,
 	BPF_PROG_TYPE_TRACEPOINT,
 	BPF_PROG_TYPE_XDP,
+	BPF_PROG_TYPE_PERF_EVENT,
+	__MAX_BPF_PROG_TYPE,
 };
 
 #define BPF_PSEUDO_MAP_FD	1
@@ -375,6 +377,56 @@ enum bpf_func_id {
 	 */
 	BPF_FUNC_probe_write_user,
 
+	/**
+	 * bpf_current_task_under_cgroup(map, index) - Check cgroup2 membership of current task
+	 * @map: pointer to bpf_map in BPF_MAP_TYPE_CGROUP_ARRAY type
+	 * @index: index of the cgroup in the bpf_map
+	 * Return:
+	 *   == 0 current failed the cgroup2 descendant test
+	 *   == 1 current succeeded the cgroup2 descendant test
+	 *    < 0 error
+	 */
+	BPF_FUNC_current_task_under_cgroup,
+
+	/**
+	 * bpf_skb_change_tail(skb, len, flags)
+	 * The helper will resize the skb to the given new size,
+	 * to be used f.e. with control messages.
+	 * @skb: pointer to skb
+	 * @len: new skb length
+	 * @flags: reserved
+	 * Return: 0 on success or negative error
+	 */
+	BPF_FUNC_skb_change_tail,
+
+	/**
+	 * bpf_skb_pull_data(skb, len)
+	 * The helper will pull in non-linear data in case the
+	 * skb is non-linear and not all of len are part of the
+	 * linear section. Only needed for read/write with direct
+	 * packet access.
+	 * @skb: pointer to skb
+	 * @len: len to make read/writeable
+	 * Return: 0 on success or negative error
+	 */
+	BPF_FUNC_skb_pull_data,
+
+	/**
+	 * bpf_csum_update(skb, csum)
+	 * Adds csum into skb->csum in case of CHECKSUM_COMPLETE.
+	 * @skb: pointer to skb
+	 * @csum: csum to add
+	 * Return: csum on success or negative error
+	 */
+	BPF_FUNC_csum_update,
+
+	/**
+	 * bpf_set_hash_invalid(skb)
+	 * Invalidate current skb>hash.
+	 * @skb: pointer to skb
+	 */
+	BPF_FUNC_set_hash_invalid,
+
 	__BPF_FUNC_MAX_ID,
 };
 
-- 
2.9.3
