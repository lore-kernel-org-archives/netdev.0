From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the percpu tree with the net tree
Date: Wed, 3 Feb 2010 16:38:03 +1100
Message-ID: <20100203163803.820597d1.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Linus <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Tejun Heo <tj@kernel.org>, Rusty Russell <rusty@rustcorp.com.au>,
	Christoph Lameter <cl@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the percpu tree got a conflict in
net/ipv6/proc.c between commit 5833929cc2ad2b3064b4fac8c44e293972d240d8
("net: constify MIB name tables") from the net tree and commit
d3f5fa4075414c7754126fbdc7c8fbd3906db7c8 ("percpu: add __percpu sparse
annotations to net") from the percpu tree.

I fixed it up (see below) and can carry the fix as necessary.

Maybe you guys could send Linus a simple one line patch for v2.6.33 that
adds

#define __percpu

to include/linux/compiler.h (unconditionally) and then farm out the
patches that add the __percpu annotations to other maintainers.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/ipv6/proc.c
index bfe2598,e3744d1..0000000
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@@ -170,8 -170,9 +170,8 @@@ static void snmp6_seq_show_icmpv6msg(st
  	return;
  }
  
- static void snmp6_seq_show_item(struct seq_file *seq, void **mib,
 -static inline void
 -snmp6_seq_show_item(struct seq_file *seq, void __percpu **mib,
 -		    struct snmp_mib *itemlist)
++static void snmp6_seq_show_item(struct seq_file *seq, void __percpu **mib,
 +				const struct snmp_mib *itemlist)
  {
  	int i;
  	for (i=0; itemlist[i].name; i++)
