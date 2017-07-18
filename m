From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH v2 net-next 0/3] liquidio: avoid vm low memory crashes
Date: Mon, 17 Jul 2017 17:49:20 -0700
Message-ID: <20170718004920.GA1541@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0048.outbound.protection.outlook.com ([104.47.37.48]:49729
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751525AbdGRAlk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Jul 2017 20:41:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Farrington <ricardo.farrington@cavium.com>

This patchset addresses issues brought about by low memory conditions
in a VM.  These conditions were not seen when the driver was exercised
normally.  Rather, they were brought about through manual fault injection.
They are being included in the interest of hardening the driver against
unforeseen circumstances.

1. Fix GPF in octeon_init_droq(); zero the allocated block 'recv_buf_list'.
   This prevents a GPF trying to access an invalid 'recv_buf_list[i]' entry
   in octeon_droq_destroy_ring_buffers() if init didn't alloc all entries.
2. Don't dereference a NULL ptr in octeon_droq_destroy_ring_buffers().
3. For defensive programming, zero the allocated block 'oct->droq[0]' in
   octeon_setup_output_queues() and 'oct->instr_queue[0]' in    
   octeon_setup_instr_queues().

change log:
V1 -> V2:
1. Corrected syntax in 'Subject' lines; no functional or code changes.

Rick Farrington (3):
  liquidio: lowmem: init allocated memory to 0
  liquidio: lowmem: do not dereference null ptr
  liquidio: lowmem: init allocated memory to 0

 drivers/net/ethernet/cavium/liquidio/octeon_device.c | 8 ++++----
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c   | 6 ++++--
 2 files changed, 8 insertions(+), 6 deletions(-)

-- 
2.9.0
