From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH v4 net-next 0/4] net: low latency sockets
	follow ups
Date: Fri, 14 Jun 2013 04:56:38 +0300
Message-ID: <20130614015638.3500.61523.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Or Kehati <ork@mellanox.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, Amir Vadai <amirv@mellanox.com>,
	linux-kernel@vger.kernel.org, Alex Rosenbaum <alexr@mellanox.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	sockperf-dev@googlegroups.com, Avner Ben Hanoch <avnerb@mellanox.com>,
	Andi Kleen <andi@firstfloor.org>, Eliezer Tamir <eliezer@tamir.org.il>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eric Dumazet <erdnetdev@gmail.com>, Eilon Greenstien <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

David,

Here are three clean up patches, plus one that adds a socket option for LLS.

Patch 1 converts sysctl_net_ll_poll into an unsigned int
Patch 2 converts low latency sockets to sched_clock.
Patch 3 removes the config menu for NET_LL_RX_POLL and defaults to y.
Patch 4 adds an SO_LL socket option to allow per-socket control of busy polling.

I will reply to this thread with a patch to sockperf that enables
the socket option. (unchanged from v2)

Again, thanks to everyone for their comments.

-Eliezer


Change log:
v4
- Fixed possible overflow, pointed out by Eric Dumazet.
  (reordered the patches)

v3
- Suggested by David Miller and Stephen Hemminger:
  added a patch to covert from get_cycles() to sched_clock(),
  remove dependency on X86_TSC.
- Suggested by Eric Dumazet:
  un-exported sysctl_net_ll_poll since for now it's not needed in modules.

v2
- added a patch to convert sysctl_net_ll_poll into an unsigned int.
- suggested by Eric Dimazet: treat sk_ll_usec as a u_int rather than a u_long.
- suggested by Ben Huchings: allow unprivileged user to decrease SO_LL value,
  correct return value when operation is not allowed.


------------------------------------------------------------------------------
This SF.net email is sponsored by Windows:

Build for Windows Store.

http://p.sf.net/sfu/windows-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
