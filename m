From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the s390 tree
Date: Wed, 22 Feb 2017 10:15:16 +1100
Message-ID: <20170222101516.2f516e2d@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  arch/s390/net/bpf_jit_comp.c

between commit:

  9437964885f8 ("s390/bpf: remove redundant check for non-null image")

from the s390 tree and commit:

  9d876e79df6a ("bpf: fix unlocking of jited image when module ronx not set")

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

diff --cc arch/s390/net/bpf_jit_comp.c
index b3b0af86b84e,b49c52a02087..000000000000
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@@ -1331,11 -1323,14 +1323,11 @@@ struct bpf_prog *bpf_int_jit_compile(st
  	}
  	if (bpf_jit_enable > 1) {
  		bpf_jit_dump(fp->len, jit.size, pass, jit.prg_buf);
 -		if (jit.prg_buf)
 -			print_fn_code(jit.prg_buf, jit.size_prg);
 -	}
 -	if (jit.prg_buf) {
 -		bpf_jit_binary_lock_ro(header);
 -		fp->bpf_func = (void *) jit.prg_buf;
 -		fp->jited = 1;
 +		print_fn_code(jit.prg_buf, jit.size_prg);
  	}
- 	set_memory_ro((unsigned long)header, header->pages);
++	bpf_jit_binary_lock_ro(header);
 +	fp->bpf_func = (void *) jit.prg_buf;
 +	fp->jited = 1;
  free_addrs:
  	kfree(jit.addrs);
  out:
