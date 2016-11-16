From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 17 Nov 2016 10:51:38 +1100
Message-ID: <20161117105138.0462666f@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Josef Bacik <jbacik@fb.com>,
        Tobias Klauser <tklauser@distanz.ch>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  kernel/bpf/verifier.c

between commit:

  f23cc643f9ba ("bpf: fix range arithmetic for bpf map access")

from the net tree and commit:

  de464375daf0 ("bpf: Remove unused but set variables")

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

diff --cc kernel/bpf/verifier.c
index 6a936159c6e0,89f787ca47ef..000000000000
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@@ -212,12 -229,13 +229,13 @@@ static void print_verifier_state(struc
  		else if (t == CONST_PTR_TO_MAP || t == PTR_TO_MAP_VALUE ||
  			 t == PTR_TO_MAP_VALUE_OR_NULL ||
  			 t == PTR_TO_MAP_VALUE_ADJ)
- 			verbose("(ks=%d,vs=%d)",
+ 			verbose("(ks=%d,vs=%d,id=%u)",
  				reg->map_ptr->key_size,
- 				reg->map_ptr->value_size);
+ 				reg->map_ptr->value_size,
+ 				reg->id);
  		if (reg->min_value != BPF_REGISTER_MIN_RANGE)
 -			verbose(",min_value=%llu",
 -				(unsigned long long)reg->min_value);
 +			verbose(",min_value=%lld",
 +				(long long)reg->min_value);
  		if (reg->max_value != BPF_REGISTER_MAX_RANGE)
  			verbose(",max_value=%llu",
  				(unsigned long long)reg->max_value);
@@@ -1477,9 -1498,7 +1499,8 @@@ static void adjust_reg_min_max_vals(str
  				    struct bpf_insn *insn)
  {
  	struct bpf_reg_state *regs = env->cur_state.regs, *dst_reg;
 -	u64 min_val = BPF_REGISTER_MIN_RANGE, max_val = BPF_REGISTER_MAX_RANGE;
 +	s64 min_val = BPF_REGISTER_MIN_RANGE;
 +	u64 max_val = BPF_REGISTER_MAX_RANGE;
- 	bool min_set = false, max_set = false;
  	u8 opcode = BPF_OP(insn->code);
  
  	dst_reg = &regs[insn->dst_reg];
