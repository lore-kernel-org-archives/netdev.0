From: Jiri Kosina <jikos@kernel.org>
Subject: [PATCH next-next 0/2] qdisc-hashtable fixes
Date: Tue, 16 Aug 2016 23:52:08 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1608162339050.22028@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Simon Horman <simon.horman@netronome.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Phil Sutter <phil@nwl.cc>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	David Ahern <dsa@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following two patches fix all the issues that have been reported 
against the conversion of qdisc linked list to hashtable (currently in 
net-next) so far.

First patch adjusts handling of singleton qdiscs to the new semantics, and 
is rather straightforward.

The second patch, which fixes "cosmetic" issue of duplicate entries in the 
qdisc dump for ingress qdiscs, is a little bit more hairy; I personally 
would love to see all the already existing "if (ingress)"-like hacks go 
away (by, let's say, introducing a general TCQ_F_? flag), but that's way 
out of scope of this patchset (but already on my todo).

Thanks a lot to Daniel Borkmann and David Ahern for reporting the issues 
and testing the patches promptly.

Jiri Kosina (2):
      net: sched: fix handling of singleton qdiscs with qdisc_hash
      net: sched: avoid duplicates in qdisc dump

 net/sched/sch_api.c | 22 +++++++++++++++++++---
 1 file changed, 19 insertions(+), 3 deletions(-)

-- 
Jiri Kosina
SUSE Labs
