From: Anjali Singhai Jain <anjali.singhai@intel.com>
Subject: [PATCH v4 0/5] Add support for Geneve udp port offload
Date: Mon, 14 Dec 2015 11:57:55 -0800
Message-ID: <1450123080-206406-1-git-send-email-anjali.singhai@intel.com>
Cc: jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:45318 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751166AbbLNTlR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Dec 2015 14:41:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds new ndo ops for Geneve add/del port, so as
to help offload Geneve tunnel functionalities such as RX checksum,
RSS, filters etc.

i40e driver has been tested with the changes to make sure the offloads
happen.

We do understand that this is not the ideal solution and most likely
will be redone with a more generic offload framework.
But this certainly will enable us to start seeing benefits of the
accelerations for Geneve tunnels.

As a side note, we did find an existing issue in i40e driver where a
service task can modify tunnel data structures with no locks held to
help linearize access. A separate patch will be taking care of that issue.

A question out to the community is regarding the driver Kconfig parameters
for VxLAN and Geneve, it would be ideal to drop those if there is a way
to help resolve vxlan/geneve_get_rx_port symbols while the tunnel modules
are not loaded.

Performance numbers:
With the offloads enable on X722 devices with remote checksum enabled
and no other tuning in terms of cpu governer etc on my test machine:

With offload
Throughput: 5527Mbits/sec with a single thread
%cpu: ~43% per core with 4 threads

Without offload
Throughput: 2364Mbits/sec with a single thread
%cpu: ~99% per core with 4 threads

These numbers will get better for X722 as it is being worked. But
this does bring out the delta in terms of when the stack is notified
with csum_level 1 and CHECKSUM_UNNECESSARY vs not without the RX offload.

v4: Comment fix and split a patch into two.

Anjali Singhai Jain (5):
  geneve: Add geneve udp port offload for ethernet devices
  i40e: geneve tunnel offload support
  i40e: Kernel dependency update for i40e to support geneve offload
  geneve: Add geneve_get_rx_port support
  i40e: Call geneve_get_rx_port to get the existing Geneve ports
