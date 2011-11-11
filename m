From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH net-next v2 00/10] forcedeth: stats & debug enhancements
Date: Thu, 10 Nov 2011 17:31:25 -0800
Message-ID: <cover.1320974990.git.david.decotigny@google.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	David Decotigny <david.decotigny@google.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f202.google.com ([209.85.160.202]:36530 "EHLO
	mail-gy0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753184Ab1KKBze (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2011 20:55:34 -0500
Received: by gye5 with SMTP id 5so290538gye.1
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2011 17:55:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These changes implement the ndo_get_stats64 API and add a few more
stats and debugging features for forcedeth. They also ensure that
stats updates are correct in SMP systems, 32 or 64-bits.

Changes since v1:
  - patch 1/10 is the same as
    http://patchwork.ozlabs.org/patch/125017/ (targetting net)
  - other patches updated to take patch 1/10 into account
  - various commit message updates


Tested:
  ~150Mbps incoming TCP, ethtool -S in a loop, x86_64 16-way:
     tx_bytes: 1413863329
     rx_packets: 38918872
     tx_packets: 19828148
     rx_bytes: 57818685991

############################################
# Patch Set Summary:

David Decotigny (8):
  forcedeth: fix ifconfig stats on hardware without extended stats
    support
  forcedeth: expose module parameters in /sys/module
  forcedeth: stats for rx_packets based on hardware registers
  forcedeth: implement ndo_get_stats64() API
  forcedeth: account for dropped RX frames
  forcedeth: new ethtool stat counter for TX timeouts
  forcedeth: stats updated with a deferrable timer
  forcedeth: whitespace/indentation fixes

Mike Ditto (1):
  forcedeth: Add messages to indicate using MSI or MSI-X

Sameer Nanda (1):
  forcedeth: allow to silence "TX timeout" debug messages

 drivers/net/ethernet/nvidia/forcedeth.c |  314 ++++++++++++++++++++++---------
 1 files changed, 225 insertions(+), 89 deletions(-)

-- 
1.7.3.1
