From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH v2 00/10] pktgen: cleanups and introducing new
	samples/pktgen scripts
Date: Thu, 21 May 2015 12:11:27 +0200
Message-ID: <20150521101003.15044.82190.stgit@ivy>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Daniel Borkmann <borkmann@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Robert Olsson <robert@herjulf.se>,
	Ben Greear <greearb@candelatech.com>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43521 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754812AbbEUKLf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2015 06:11:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2: address nitpicks from Cong Wang
 - Remove useless cat's, but keep them for old pgset()
 - Comment on: Due to pgctrl, cannot use exit code $? from grep
 - Use arithmetic compare in pktgen_sample03_burst_single_flow.sh

This patchset is focused on making pktgen easier to use and better
documented. It contains a number of documentation updates and minor
changes to pktgen.  The major contribution is introduction of common
helper function for sample scripts.

Instead of the old pgset() function, three new shell functions for
configuring the different components of pktgen are introduced:
 pg_ctrl(), pg_thread() and pg_set().

The new functions correspond to pktgens different components.
 * pg_ctrl()   control "pgctrl" (/proc/net/pktgen/pgctrl)
 * pg_thread() control the kernel threads and binding to devices
 * pg_set()    control setup of individual devices

Helpers also provide consistent parameter parsing across the sample
scripts.

Usage example:
 ./pktgen_sample01_simple.sh -i eth41 -m 00:12:C0:02:AC:5A -d 192.168.41.2

Usage: ./pktgen_sample01_simple.sh [-vx] -i ethX
  -i : ($DEV)       output interface/device (required)
  -s : ($PKT_SIZE)  packet size
  -d : ($DEST_IP)   destination IP
  -m : ($DST_MAC)   destination MAC-addr
  -t : ($THREADS)   threads to start
  -c : ($SKB_CLONE) SKB clones send before alloc new SKB
  -b : ($BURST)     HW level bursting of SKBs
  -v : ($VERBOSE)   verbose
  -x : ($DEBUG)     debug

These scripts are borrowed from:
 https://github.com/netoptimizer/network-testing/tree/master/pktgen

---

Jesper Dangaard Brouer (10):
      pktgen: add benchmark script pktgen_bench_xmit_mode_netif_receive.sh
      pktgen: add sample script pktgen_sample03_burst_single_flow.sh
      pktgen: add sample script pktgen_sample02_multiqueue.sh
      pktgen: add sample script pktgen_sample01_simple.sh
      pktgen: new pktgen helper functions for samples scripts
      pktgen: make /proc/net/pktgen/pgctrl report fail on invalid input
      pktgen: document ability to add same device to several threads
      pktgen: doc were missing several config options
      pktgen: adjust spacing in proc file interface output
      pktgen: remove obsolete "max_before_softirq" from pktgen doc


 samples/pktgen/README.rst                          |   43 +++++++
 samples/pktgen/functions.sh                        |  121 ++++++++++++++++++++
 samples/pktgen/parameters.sh                       |   97 ++++++++++++++++
 samples/pktgen/pktgen.conf-1-1                     |   59 ----------
 samples/pktgen/pktgen.conf-2-1                     |   66 -----------
 samples/pktgen/pktgen.conf-2-2                     |   73 ------------
 .../pktgen/pktgen_bench_xmit_mode_netif_receive.sh |   86 ++++++++++++++
 samples/pktgen/pktgen_sample01_simple.sh           |   71 ++++++++++++
 samples/pktgen/pktgen_sample02_multiqueue.sh       |   75 ++++++++++++
 .../pktgen/pktgen_sample03_burst_single_flow.sh    |   82 ++++++++++++++
 10 files changed, 575 insertions(+), 198 deletions(-)
 create mode 100644 samples/pktgen/README.rst
 create mode 100644 samples/pktgen/functions.sh
 create mode 100644 samples/pktgen/parameters.sh
 delete mode 100755 samples/pktgen/pktgen.conf-1-1
 delete mode 100755 samples/pktgen/pktgen.conf-2-1
 delete mode 100755 samples/pktgen/pktgen.conf-2-2
 create mode 100755 samples/pktgen/pktgen_bench_xmit_mode_netif_receive.sh
 create mode 100755 samples/pktgen/pktgen_sample01_simple.sh
 create mode 100755 samples/pktgen/pktgen_sample02_multiqueue.sh
 create mode 100755 samples/pktgen/pktgen_sample03_burst_single_flow.sh

-- 
