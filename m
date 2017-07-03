From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the arm64 tree
Date: Mon, 3 Jul 2017 11:37:32 +1000
Message-ID: <20170703113732.6af8235d@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
        Will Deacon <will.deacon@arm.com>,
        Daniel Borkmann <daniel@iogearbox.net>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Catalin Marinas <catalin.marinas@arm.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  arch/arm64/net/bpf_jit_comp.c

between commit:

  425e1ed73e65 ("arm64: fix endianness annotation for 'struct jit_ctx' and friends")

from the arm64 tree and commit:

  f1c9eed7f437 ("bpf, arm64: take advantage of stack_depth tracking")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc arch/arm64/net/bpf_jit_comp.c
index 8860bb9c33a1,2f0505b5c240..000000000000
--- a/arch/arm64/net/bpf_jit_comp.c
+++ b/arch/arm64/net/bpf_jit_comp.c
@@@ -70,7 -70,8 +70,8 @@@ struct jit_ctx 
  	int idx;
  	int epilogue_offset;
  	int *offset;
 -	u32 *image;
 +	__le32 *image;
+ 	u32 stack_size;
  };
  
  static inline void emit(const u32 insn, struct jit_ctx *ctx)
