From: Joe Stringer <joe@ovn.org>
Subject: [PATCH net-next 1/3] tools lib bpf: Sync {tools,}/include/uapi/linux/bpf.h
Date: Mon, 31 Oct 2016 11:39:15 -0700
Message-ID: <20161031183917.9938-2-joe@ovn.org>
References: <20161031183917.9938-1-joe@ovn.org>
Cc: wangnan0@huawei.com, ast@fb.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:60425 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S945567AbcJaSq4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 14:46:56 -0400
Received: from relay2-d.mail.gandi.net (relay2-d.mail.gandi.net [217.70.183.194])
        by slow1-d.mail.gandi.net (Postfix) with ESMTP id 716F847AAE0
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 19:39:36 +0100 (CET)
In-Reply-To: <20161031183917.9938-1-joe@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tools version of this header is out of date; update it to the latest
version from the kernel headers.

Signed-off-by: Joe Stringer <joe@ovn.org>
---
 tools/include/uapi/linux/bpf.h | 51 ++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 51 insertions(+)

diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index 9e5fc168c8a3..f09c70b97eca 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -95,6 +95,7 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_SCHED_ACT,
 	BPF_PROG_TYPE_TRACEPOINT,
 	BPF_PROG_TYPE_XDP,
+	BPF_PROG_TYPE_PERF_EVENT,
 };
 
 #define BPF_PSEUDO_MAP_FD	1
@@ -375,6 +376,56 @@ enum bpf_func_id {
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
