From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Fri, 26 Feb 2016 11:13:14 +1100
Message-ID: <20160226111314.5b94099c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@fb.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  include/uapi/linux/bpf.h

between commit:

  2da897e51d7f ("bpf: fix csum setting for bpf_set_tunnel_key")

from the net tree and commit:

  d5a3b1f69186 ("bpf: introduce BPF_MAP_TYPE_STACK_TRACE")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

-- 
Cheers,
Stephen Rothwell

diff --cc include/uapi/linux/bpf.h
index 5df4881dea7b,6496f98d3d68..000000000000
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@@ -292,9 -321,12 +321,15 @@@ enum bpf_func_id 
  /* BPF_FUNC_skb_set_tunnel_key and BPF_FUNC_skb_get_tunnel_key flags. */
  #define BPF_F_TUNINFO_IPV6		(1ULL << 0)
  
 +/* BPF_FUNC_skb_set_tunnel_key flags. */
 +#define BPF_F_ZERO_CSUM_TX		(1ULL << 1)
 +
+ /* BPF_FUNC_get_stackid flags. */
+ #define BPF_F_SKIP_FIELD_MASK		0xffULL
+ #define BPF_F_USER_STACK		(1ULL << 8)
+ #define BPF_F_FAST_STACK_CMP		(1ULL << 9)
+ #define BPF_F_REUSE_STACKID		(1ULL << 10)
+ 
  /* user accessible mirror of in-kernel sk_buff.
   * new fields can only be added to the end of this structure
   */
