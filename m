From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: [net-next PATCH 0/2] NAPI ID fixups related to busy polling
Date: Mon, 20 Mar 2017 14:48:41 -0700
Message-ID: <20170320214643.13922.51284.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sridhar.samudrala@intel.com, edumazet@google.com,
        davem@davemloft.net
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These two patches are a couple of minor clean-ups related to busy polling.
The first one addresses the fact that we were trying to busy poll on
sender_cpu values instead of true NAPI IDs.  The second addresses the fact
that there were a few paths where TCP sockets were being instanciated based
on a received patcket, but not recording the hash or NAPI ID of the packet
that was used to instanciate them.

---

Alexander Duyck (2):
      net: Busy polling should ignore sender CPUs
      tcp: Record Rx hash and NAPI ID in tcp_child_process


 include/net/busy_poll.h  |   11 +++++++++--
 net/core/dev.c           |    6 +++---
 net/ipv4/tcp_ipv4.c      |    2 --
 net/ipv4/tcp_minisocks.c |    5 +++++
 net/ipv6/tcp_ipv6.c      |    2 --
 5 files changed, 17 insertions(+), 9 deletions(-)

--
