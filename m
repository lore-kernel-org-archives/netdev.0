From: Arun Parameswaran <aparames@broadcom.com>
Subject: [PATCH 0/1] Fix an issue with 'ethtool' configuring PHYs
Date: Wed, 20 May 2015 14:35:29 -0700
Message-ID: <1432157730-26865-1-git-send-email-aparames@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<bcm-kernel-feedback-list@broadcom.com>, <rjui@broadcom.com>,
	<aparames@broadcom.com>, <sbranden@broadcom.com>,
	<jdzheng@broadcom.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:55002 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932234AbbETVgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 17:36:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch fixes an issue while using the 'ethtool' to query/set PHY's
configurations. The 'ethtool' interface in the Kernel seem to always
query settings for PHY0, irrespective of the PHY specified, while
issuing the 'ethtool' command.

For example when issueing 'ethtool -s eth0 phyad 1 speed 100' command
to set the speed of PHY1's speed, the current software would first
retrieve PHY0 settings, then apply the request settings (in this case
'speed') on top. It then uses this (PHY0's config with new speed)
settings to update the PHY1, which now ends up with partial
configurations of PHY0 and the new speed.

This patch series is based on Linux v4.1-rc4 and is available in:
https://github.com/Broadcom/cygnus-linux/tree/net-core-ethtool-fix-v1

Arun Parameswaran (1):
  SWMAPYVR-4339 net: core: 'ethtool' issue with querying phy settings

 net/core/ethtool.c |   10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

-- 
1.7.9.5
