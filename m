From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 tip/core/rcu 07/13] ipv6/ip6_tunnel: Apply
 rcu_access_pointer() to avoid sparse false positive
Date: Wed, 09 Oct 2013 15:51:17 -0700
Message-ID: <1381359077.4971.37.camel@edumazet-glaptop.roam.corp.google.com>
References: <20131009212920.GA15413@linux.vnet.ibm.com>
	 <1381354186-16285-1-git-send-email-paulmck@linux.vnet.ibm.com>
	 <1381354186-16285-7-git-send-email-paulmck@linux.vnet.ibm.com>
	 <1381354949.4971.20.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131009215747.GA5790@linux.vnet.ibm.com>
	 <1381356624.4971.26.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131009223652.GC5790@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, mingo@kernel.org,
	laijs@cn.fujitsu.com, dipankar@in.ibm.com,
	akpm@linux-foundation.org, mathieu.desnoyers@efficios.com,
	josh@joshtriplett.org, niv@us.ibm.com, tglx@linutronix.de,
	peterz@infradead.org, rostedt@goodmis.org, dhowells@redhat.com,
	edumazet@google.com, darren@dvhart.com, fweisbec@gmail.com,
	sbw@mit.edu, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131009223652.GC5790@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-10-09 at 15:36 -0700, Paul E. McKenney wrote:

> That would work, though it would probably give sparse complaints.

No sparse error here, as I said types are correct and SPARSE_RCU ready :

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 583b77e..28f8495 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -245,7 +245,7 @@ ip6_tnl_unlink(struct ip6_tnl_net *ip6n, struct ip6_tnl *t)
             (iter = rtnl_dereference(*tp)) != NULL;
             tp = &iter->next) {
                if (t == iter) {
-                       rcu_assign_pointer(*tp, t->next);
+                       ACCESS_ONCE(*tp) = t->next;
                        break;
                }
        }

root@edumazet-glaptop:/usr/src/net-next# grep CONFIG_SPARSE_RCU_POINTER .config
CONFIG_SPARSE_RCU_POINTER=y

root@edumazet-glaptop:/usr/src/net-next# make C=2 net/ipv6/ip6_tunnel.o
make[1]: Nothing to be done for `all'.
make[1]: Nothing to be done for `relocs'.
  CHK     include/config/kernel.release
  CHK     include/generated/uapi/linux/version.h
  CHK     include/generated/utsrelease.h
  CALL    scripts/checksyscalls.sh
  CHECK   scripts/mod/empty.c
  CHECK   net/ipv6/ip6_tunnel.c
