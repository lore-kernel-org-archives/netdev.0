From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH v5 net-next 0/4] net: low latency sockets follow ups
Date: Fri, 14 Jun 2013 16:33:14 +0300
Message-ID: <20130614133314.6126.77315.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <erdnetdev@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	Alex Rosenbaum <alexr@mellanox.com>,
	Avner Ben Hanoch <avnerb@mellanox.com>,
	Or Kehati <ork@mellanox.com>, sockperf-dev@googlegroups.com,
	Eliezer Tamir <eliezer@tamir.org.il>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
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
v5 
- use time_after64() instead of time_after, suggested by Eric Dumazet.

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
