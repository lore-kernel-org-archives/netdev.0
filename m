From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH v10 net-next 0/6] net: low latency Ethernet device polling
Date: Mon, 10 Jun 2013 11:39:30 +0300
Message-ID: <20130610083929.6955.87206.stgit@ladj378.jer.intel.com>
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
	Eliezer Tamir <eliezer@tamir.org.il>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,

I removed the select/poll patch (was 5/7 in v9) from the set.
The rest are the same patches that were in v9.

Please consider applying.

Thanks to everyone for their input.

-Eliezer

Change log:
v10
- removed select/poll support. (we will work on this some more and try again)
v9
- correct sysctl proc_handler, reported by Eric Dumazet and Amir Vadai.
- more int -> bool changes, reported by Eric Dumazet.
- better mask testing in sock_poll(), reported by Eric Dumazet.

v8
- split out udp and select/poll into separate patches.
  what used to be patch 2/5 is now three patches.
- type corrections from Amir Vadai and Cong Wang:
  one unsigned long that was left when changing to cycles_t
  int -> bool 
- more detailed patch descriptions.

v7
- suggested by Ben Hutchings and Eric Dumazet:
  type fixes, static for globals in net/core.c,
  avoid napi_id collisions in napi_hash_add()

v6
- many small fixes suggested by Eric Dumazet:
  data locality, typos, documentation
  protect napi_hash insert/delete with a spinlock (napi_gen_id is no
  longer atomic_t since it's only accessed with the spinlock held.)
- added IPv6 TCP and UDP support (only minimally tested)

v5
- corrections suggested by Ben Hutchings:
  fixed typos, moved the config option and sysctl value from IPv4 to net
- moved sk_mark_ll() to the protocol handlers
- removed global id mechanism, replaced with a hashed napi_id.
  based on code sample from Eric Dumazet
  Note that ixgbe_free_q_vector() already waits an rcu grace period
  before freeing the q_vector, so nothing additional needs to be done
  when adding a call to napi_hash_del().
- simple poll/select support

v4
- removed separate config option for TCP as suggested Eric Dumazet.
- added linux mib counter for packets received through the low latency path,
  as suggested by Andi Kleen.
- re-allow module unloading, remove module param, use a global generation id
  instead to prevent the use of a stale napi pointer, as suggested
  by Eric Dumazet
- updated Documentation/networking/ip-sysctl.txt text

v3
- coding style changes suggested by Dave Miller

v2
- the sysctl knob is now in microseconds. The default value is now 0 (off).
- for now the code depends at configure time on CONFIG_I86_TSC 
- the napi reference in struct skb is now a union with the dma cookie
  since the former is only used on RX and the latter on TX,
  as suggested by Eric Dumazet.
- we do a better job at honoring non-blocking operations.
- removed busy-polling support for tcp_read_sock()
- remove dynamic disabling of GRO
- coding style fixes
- disallow unloading the device module after the feature has been used

Credit:
Jesse Brandeburg, Arun Chekhov Ilango, Julie Cummings,
Alexander Duyck, Eric Geisler, Jason Neighbors, Yadong Li,
Mike Polehn, Anil Vasudevan, Don Wood
Special thanks for finding bugs in earlier versions:
Willem de Bruijn and Andi Kleen
