From: Anjali Singhai Jain <anjali.singhai@intel.com>
Subject: Add support for Geneve udp port offload
Date: Fri,  4 Dec 2015 00:19:00 -0800
Message-ID: <1449217144-18756-1-git-send-email-anjali.singhai@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:45409 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752542AbbLDIBv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2015 03:01:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds new ndo ops for Geneve add/del port, so as
to help offload Geneve tunnel functionalities such as checksum, TSO
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

Anjali Singhai Jain (4):
  [RFC PATCH v2 1/4] geneve: Add geneve udp port offload for ethernet
  [RFC PATCH v2 2/4] i40e: geneve tunnel offload support
  [RFC PATCH v2 3/4] i40e: Kernel dependency update for i40e to support
  [RFC PATCH v2 4/4] geneve: Add geneve_get_rx_port support
