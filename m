From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH net-next v2 1/3] tools: Sync {,tools/}include/uapi/linux/bpf.h
Date: Mon,  6 Feb 2017 21:52:23 +0100
Message-ID: <20170206205225.32233-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@fb.com>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Daniel Mack <daniel@zonque.org>,
        Gianluca Borello <g.borello@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The tools version of this header is out of date; update it to the latest
version from kernel header.

Synchronize with the following commits:
* b95a5c4db09b ("bpf: add a longest prefix match trie map implementation")
* a5e8c07059d0 ("bpf: add bpf_probe_read_str helper")
* d1b662adcdb8 ("bpf: allow option for setting bpf_l4_csum_replace from scratch")

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Daniel Mack <daniel@zonque.org>
Cc: David S. Miller <davem@davemloft.net>
Cc: Gianluca Borello <g.borello@gmail.com>
---
 tools/include/uapi/linux/bpf.h | 23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index 0eb0e87dbe9f..e07fd5a324e6 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -63,6 +63,12 @@ struct bpf_insn {
 	__s32	imm;		/* signed immediate constant */
 };
 
+/* Key of an a BPF_MAP_TYPE_LPM_TRIE entry */
+struct bpf_lpm_trie_key {
+	__u32	prefixlen;	/* up to 32 for AF_INET, 128 for AF_INET6 */
+	__u8	data[0];	/* Arbitrary size */
+};
+
 /* BPF syscall commands, see bpf(2) man-page for details. */
 enum bpf_cmd {
 	BPF_MAP_CREATE,
@@ -89,6 +95,7 @@ enum bpf_map_type {
 	BPF_MAP_TYPE_CGROUP_ARRAY,
 	BPF_MAP_TYPE_LRU_HASH,
 	BPF_MAP_TYPE_LRU_PERCPU_HASH,
+	BPF_MAP_TYPE_LPM_TRIE,
 };
 
 enum bpf_prog_type {
@@ -430,6 +437,18 @@ union bpf_attr {
  *     @xdp_md: pointer to xdp_md
  *     @delta: An positive/negative integer to be added to xdp_md.data
  *     Return: 0 on success or negative on error
+ *
+ * int bpf_probe_read_str(void *dst, int size, const void *unsafe_ptr)
+ *     Copy a NUL terminated string from unsafe address. In case the string
+ *     length is smaller than size, the target is not padded with further NUL
+ *     bytes. In case the string length is larger than size, just count-1
+ *     bytes are copied and the last byte is set to NUL.
+ *     @dst: destination address
+ *     @size: maximum number of bytes to copy, including the trailing NUL
+ *     @unsafe_ptr: unsafe address
+ *     Return:
+ *       > 0 length of the string including the trailing NUL on success
+ *       < 0 error
  */
 #define __BPF_FUNC_MAPPER(FN)		\
 	FN(unspec),			\
@@ -476,7 +495,8 @@ union bpf_attr {
 	FN(set_hash_invalid),		\
 	FN(get_numa_node_id),		\
 	FN(skb_change_head),		\
-	FN(xdp_adjust_head),
+	FN(xdp_adjust_head),		\
+	FN(probe_read_str),
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
@@ -502,6 +522,7 @@ enum bpf_func_id {
 /* BPF_FUNC_l4_csum_replace flags. */
 #define BPF_F_PSEUDO_HDR		(1ULL << 4)
 #define BPF_F_MARK_MANGLED_0		(1ULL << 5)
+#define BPF_F_MARK_ENFORCE		(1ULL << 6)
 
 /* BPF_FUNC_clone_redirect and BPF_FUNC_redirect flags. */
 #define BPF_F_INGRESS			(1ULL << 0)
-- 
2.11.0
