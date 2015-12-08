From: Anjali Singhai Jain <anjali.singhai@intel.com>
Subject: Add support for Geneve udp port offload
Date: Tue,  8 Dec 2015 10:12:10 -0800
Message-ID: <1449598334-97674-1-git-send-email-anjali.singhai@intel.com>
Cc: jeffrey.t.kirsher@intel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:10851 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751724AbbLHRzH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2015 12:55:07 -0500
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

Performance numbers
With the offloads enable on X722 devices with remote checksum enabled
and no other tuning in terms of cpu governer etc.

With offload
Throughput: 5527Mbits/sec with a single thread
%cpu: ~43% per core with 4 threads

Without offload
Throughput: 2364Mbits/sec with a single thread
%cpu: ~99% per core with 4 threads

These numbers will get better for X722 as it is being worked. But
this does bring out the delta in terms of when the stack is notified
with csum_level 1 and CHECKSUM_UNNECESSARY vs not without the RX offload.

Anjali Singhai Jain (4):
  [RFC PATCH v2 1/4] geneve: Add geneve udp port offload for ethernet
  [RFC PATCH v2 2/4] i40e: geneve tunnel offload support
  [RFC PATCH v2 3/4] i40e: Kernel dependency update for i40e to support
  [RFC PATCH v2 4/4] geneve: Add geneve_get_rx_port support
