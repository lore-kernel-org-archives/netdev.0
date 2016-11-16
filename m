From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 17 Nov 2016 10:48:53 +1100
Message-ID: <20161117104853.7c0a316d@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Josef Bacik <jbacik@fb.com>, Thomas Graf <tgraf@suug.ch>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  include/linux/bpf_verifier.h

between commit:

  f23cc643f9ba ("bpf: fix range arithmetic for bpf map access")

from the net tree and commit:

  57a09bf0a416 ("bpf: Detect identical PTR_TO_MAP_VALUE_OR_NULL registers")

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

diff --cc include/linux/bpf_verifier.h
index 6aaf425cebc3,ac5b393ee6b2..000000000000
--- a/include/linux/bpf_verifier.h
+++ b/include/linux/bpf_verifier.h
@@@ -22,8 -22,8 +22,9 @@@ struct bpf_reg_state 
  	 * Used to determine if any memory access using this register will
  	 * result in a bad access.
  	 */
 -	u64 min_value, max_value;
 +	s64 min_value;
 +	u64 max_value;
+ 	u32 id;
  	union {
  		/* valid when type == CONST_IMM | PTR_TO_STACK | UNKNOWN_VALUE */
  		s64 imm;
