From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/3] net: Switch tag HW extraction/insertion
Date: Wed, 29 Jul 2015 15:32:37 -0700
Message-ID: <1438209160-6898-1-git-send-email-f.fainelli@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr,
	Chris.Packham@alliedtelesis.co.nz
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

This patch series adds two new feature flags to allow Ethernet controllers
capable of doing Ethernet switch proprietary tag insertion/extraction to
benefit from that.

The last two patches modify the Broadcom tag parsing code in DSA to utilize
that feature and finally, the SYSTEMPORT controller driver is updated to
turn on that feature when requested.

The ethtool patch will follow-up shortly as well.

Insertion on transmit is still work in progress and requires more turning on
how the SYSTEMPORT transmit queues are mapped to their respective switch ports
and queues (there are 32 queues on SYSTEMPORT to output to a 4-port switch each
port with 8 transmit queues).

Florian Fainelli (3):
  net: add flags for HW assisted extraction/insertions of switch tags
  net: dsa: tag_brcm: Support extracting tags from HW
  net: systemport: Add support for switch tag HW extraction

 drivers/net/ethernet/broadcom/bcmsysport.c | 40 +++++++++++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bcmsysport.h |  1 +
 include/linux/netdev_features.h            |  4 +++
 include/linux/netdevice.h                  | 13 ++++++++++
 include/net/dsa.h                          |  5 ++++
 include/uapi/linux/ethtool.h               |  2 ++
 net/core/ethtool.c                         | 16 ++++++++++--
 net/dsa/tag_brcm.c                         | 38 +++++++++++++++++-----------
 8 files changed, 101 insertions(+), 18 deletions(-)

-- 
2.1.0
