From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Fri, 7 Apr 2017 10:12:02 +1000
Message-ID: <20170407101202.30ec5a4e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Kosina <jkosina@suse.cz>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/sched/sch_generic.c

between commit:

  92f9170621a1 ("net_sched: check noop_qdisc before qdisc_hash_add()")

from the net tree and commit:

  49b499718fa1 ("net: sched: make default fifo qdiscs appear in the dump")

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

diff --cc net/sched/sch_generic.c
index 1a2f9e964330,3e64d23e098c..000000000000
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@@ -794,8 -794,8 +794,8 @@@ static void attach_default_qdiscs(struc
  		}
  	}
  #ifdef CONFIG_NET_SCHED
 -	if (dev->qdisc)
 +	if (dev->qdisc != &noop_qdisc)
- 		qdisc_hash_add(dev->qdisc);
+ 		qdisc_hash_add(dev->qdisc, false);
  #endif
  }
  
