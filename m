From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next 0/3] LiquidIO: avoid VM low memory crashes
Date: Wed, 7 Jun 2017 20:50:45 -0700
Message-ID: <20170608035045.GA1608@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0049.outbound.protection.outlook.com ([104.47.34.49]:43696
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751502AbdFHDu7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Jun 2017 23:50:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Farrington <ricardo.farrington@cavium.com>

This patchset addresses issues brought about by low memory conditions
in a VM.  These conditions were only seen when VM's were intentionally
created with small amounts of memory (for stress testing).

1. Fix GPF in octeon_init_droq(); zero the allocated block 'recv_buf_list'.
   This prevents a GPF trying to access an invalid 'recv_buf_list[i]' entry
   in octeon_droq_destroy_ring_buffers() if init didn't alloc all entries.
2. Don't dereference a NULL ptr in octeon_droq_destroy_ring_buffers().
3. For defensive programming, zero the allocated block 'oct->droq[0]' in
   octeon_setup_output_queues() and 'oct->instr_queue[0]' in    
   octeon_setup_instr_queues().

 drivers/net/ethernet/cavium/liquidio/octeon_device.c | 8 ++++----
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c   | 6 ++++--
 2 files changed, 8 insertions(+), 6 deletions(-)

-- 
1.8.3.1
