From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/2 v2] net: dsa: remove restriction on platform_device
Date: Mon,  9 Mar 2015 14:31:19 -0700
Message-ID: <1425936681-31910-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr,
	Chris.Packham@alliedtelesis.co.nz
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:38707 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754189AbbCIVby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 17:31:54 -0400
Received: by pabrd3 with SMTP id rd3so51719336pab.5
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 14:31:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series removes the restriction in DSA to operate exclusively with
platform_device Ethernet MAC drivers when using Device Tree. This basically
allows arbitrary Ethernet MAC drivers to be used now in conjunction with
Device Tree.

The reason was that DSA was using a of_find_device_by_node() which limits
the device_node to device pointer search exclusively to platform_device,
in our case, we are interested in doing a "class" research and lookup the
net_device.

Thanks to Chris Packham for testing this on his platform.

Changes in v2:

- fix build for !CONFIG_OF_NET

Florian Fainelli (2):
  net: core: add of_find_net_device_by_node()
  net: dsa: utilize of_find_net_device_by_node

 include/linux/of_net.h |  8 ++++++++
 include/net/dsa.h      |  1 +
 net/core/net-sysfs.c   | 25 +++++++++++++++++++++++++
 net/dsa/dsa.c          | 16 +++++++++++-----
 4 files changed, 45 insertions(+), 5 deletions(-)

-- 
2.1.0
