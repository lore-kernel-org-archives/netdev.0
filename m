From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V2 0/3] Optimizing pktgen for single CPU performance
Date: Thu, 26 Jun 2014 13:16:17 +0200
Message-ID: <20140626111549.23576.90201.stgit@dragon>
References: <20140514141545.20309.28343.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>, zoltan.kiss@citrix.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30039 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755679AbaFZLQ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2014 07:16:57 -0400
In-Reply-To: <20140514141545.20309.28343.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series focus on optimizing "pktgen" for single CPU performance.

V2-series:
 - Removed some patches
 - Doc real reason for TX ring buffer filling up

NIC tuning for pktgen:
 http://netoptimizer.blogspot.dk/2014/06/pktgen-for-network-overload-testing.html

General overload setup according to:
 http://netoptimizer.blogspot.dk/2014/04/basic-tuning-for-network-overload.html

Hardware:
 System: CPU E5-2630
 NIC: Intel ixgbe/82599 chip

Testing done with net-next git tree on top of
 commit 6623b41944 ("Merge branch 'master' of...jkirsher/net-next")

Pktgen script exercising race condition:
 https://github.com/netoptimizer/network-testing/blob/master/pktgen/unit_test01_race_add_rem_device_loop.sh

Tool for measuring LOCK overhead:
 https://github.com/netoptimizer/network-testing/blob/master/src/overhead_cmpxchg.c

---

Jesper Dangaard Brouer (3):
      pktgen: RCU-ify "if_list" to remove lock in next_to_run()
      pktgen: avoid expensive set_current_state() call in loop
      pktgen: document tuning for max NIC performance


 Documentation/networking/pktgen.txt |   28 +++++++++
 net/core/pktgen.c                   |  110 ++++++++++++++++++-----------------
 2 files changed, 83 insertions(+), 55 deletions(-)

-- 
