From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the kspp tree with the net-next tree
Date: Mon, 20 Feb 2017 10:56:42 +1100
Message-ID: <20170220105642.616b119b@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Laura Abbott <labbott@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>
To: Kees Cook <keescook@google.com>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Kees,

Today's linux-next merge of the kspp tree got a conflict in:

  include/linux/filter.h

between commit:

  74451e66d516 ("bpf: make jited programs visible in traces")

from the net-next tree and commit:

  0f5bf6d0afe4 ("arch: Rename CONFIG_DEBUG_RODATA and CONFIG_DEBUG_MODULE_RONX")

from the kspp tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc include/linux/filter.h
index 0c1cc9143cb2,c6dd53e88711..000000000000
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@@ -574,21 -561,8 +574,21 @@@ static inline void bpf_prog_lock_ro(str
  static inline void bpf_prog_unlock_ro(struct bpf_prog *fp)
  {
  }
 +
 +static inline void bpf_jit_binary_unlock_ro(struct bpf_binary_header *hdr)
 +{
 +}
- #endif /* CONFIG_DEBUG_SET_MODULE_RONX */
+ #endif /* CONFIG_STRICT_MODULE_RWX */
  
 +static inline struct bpf_binary_header *
 +bpf_jit_binary_hdr(const struct bpf_prog *fp)
 +{
 +	unsigned long real_start = (unsigned long)fp->bpf_func;
 +	unsigned long addr = real_start & PAGE_MASK;
 +
 +	return (void *)addr;
 +}
 +
  int sk_filter_trim_cap(struct sock *sk, struct sk_buff *skb, unsigned int cap);
  static inline int sk_filter(struct sock *sk, struct sk_buff *skb)
  {
