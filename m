From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH v3 tip/core/rcu 0/14] Sparse-related updates for
	3.13
Date: Fri, 11 Oct 2013 16:16:59 -0700
Message-ID: <20131011231659.GA28062@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: peterz@infradead.org, fweisbec@gmail.com, dhowells@redhat.com,
	edumazet@google.com, gaofeng@cn.fujitsu.com, mingo@kernel.org,
	bridge@lists.linux-foundation.org, jmorris@namei.org,
	dipankar@in.ibm.com, darren@dvhart.com, josh@joshtriplett.org,
	rostedt@goodmis.org, niv@us.ibm.com,
	mathieu.desnoyers@efficios.com, kuznet@ms2.inr.ac.ru,
	tglx@linutronix.de, johannes@sipsolutions.net,
	laijs@cn.fujitsu.com, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, linux-decnet-user@lists.sourceforge.net,
	kaber@trash.net, stephen@networkplumber.org, sbw@mit.edu,
	tgraf@suug.ch, akpm@linux-foundation.org, fengguang.wu@intel.com,
	davem@davemloft.net
To: linux-kernel@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Hello!

This series features updates to allow sparse to do a better job of
statically analyzing RCU usage:

1.	Add a comment indicating that despite appearances,
	rcu_assign_pointer() really only evaluates its arguments once,
	as a cpp macro should.

2-13.	Apply ACCESS_ONCE() to avoid a number of rcu_assign_pointer()
	calls that would otherwise suffer sparse false positives given
	patch #13 below.

14.	Apply ACCESS_ONCE() to rcu_assign_pointer()'s target to prevent
	comiler mischief.  Also require that the source pointer be from
	the kernel address space.  Sometimes it can be from the RCU address
	space, which necessitates the remaining patches in this series.
	Which, it must be admitted, apply to a very small fraction of
	the rcu_assign_pointer() invocations in the kernel.  This commit
	courtesy of Josh Triplett.

Changes from v2:

o	Switch from rcu_assign_pointer() to ACCESS_ONCE() given that
	the pointers are all --rcu and already visible to readers,
	as suggested by Eric Dumazet and Josh Triplett.

o	Place the commit adding the rcu_assign_pointer()'s ACCESS_ONCE()
	at the end to allow better bisectability, as suggested by Josh
	Triplett.

o	Add a comment to rcu_assign_pointer() noting that it only evaluates
	its arguments once, as suggested by Josh Triplett.

Changes from v1:

o	Fix grammar nit in commit logs.

							Thanx, Paul


 b/drivers/net/bonding/bond_alb.c  |    3 ++-
 b/drivers/net/bonding/bond_main.c |    8 +++++---
 b/include/linux/rcupdate.h        |   20 +++++++++++++++++++-
 b/kernel/notifier.c               |    3 ++-
 b/net/bridge/br_mdb.c             |    2 +-
 b/net/bridge/br_multicast.c       |    4 ++--
 b/net/decnet/dn_route.c           |    8 +++++---
 b/net/ipv4/ip_sockglue.c          |    3 ++-
 b/net/ipv6/ip6_gre.c              |    3 ++-
 b/net/ipv6/ip6_tunnel.c           |    3 ++-
 b/net/ipv6/sit.c                  |    3 ++-
 b/net/mac80211/sta_info.c         |    7 ++++---
 b/net/wireless/scan.c             |   32 ++++++++++++++++++--------------
 13 files changed, 66 insertions(+), 33 deletions(-)
