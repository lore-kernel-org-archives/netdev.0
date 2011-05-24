From: Neil Horman <nhorman@tuxdriver.com>
Subject: net: enable dynamic lro disabling for vlans (v2)
Date: Tue, 24 May 2011 14:31:07 -0400
Message-ID: <1306261869-7276-1-git-send-email-nhorman@tuxdriver.com>
References: <1306257314-3925-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net,
	bhutchings@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60537 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752785Ab1EXSb0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 14:31:26 -0400
In-Reply-To: <1306257314-3925-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Noted recently that, while physical devices have lro disabled when
attached to a bridge, vlan devices do not.  This is because the vlan netdev has
no get/set flags method in its ethtool_ops struct. This series teaches
dev_disable_lro to recognize vlan interfaces and operate on the underlying
physical device instead.

Change notes:
v2) Rewrite of my origional solution As per Ben H.- instead of passing ethtool
command from the vlan device to the physical device, instead teach
dev_disable_lro to recognize vlans and operate on the underlying physical device
directly.  This lets us avoid the various oddities of operating with ethtool on
a vlan device, and is more consice to boot.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: davem@davemloft.net
CC: bhutchings@solarflare.com



