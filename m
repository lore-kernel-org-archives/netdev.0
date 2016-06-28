From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/6] net: dsa: Platform data for dsa2.c
Date: Mon, 27 Jun 2016 17:52:37 -0700
Message-ID: <1467075163-15890-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:33195 "EHLO
	mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751888AbcF1Awr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 20:52:47 -0400
Received: by mail-oi0-f66.google.com with SMTP id w141so269516oia.0
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 17:52:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series adds support for platform data using the new code from
net/dsa/dsa2.c. The motivation behind this is that we have a bit of in tree
platforms (ar7, bcm47xx, x86, others) that could be benefiting from the new
dsa_register_switch() API model but do not support Device Tree, nor is there a
plan to bring Device Tree to these platforms (time vs. benefits).

The approach taken here is to introduced a new set of platform data structures:
- dsa2_platform_data: per-switch platform data information
- dsa2_port_data: per-port platform data information
- dsa2_port_link: per-port link topology

The platform data is mapped as closely as possible to the Device Tree binding.
Where needed the code is looking either specifically for DT
attributes/properties, or parses the platform data, unlike net/dsa/dsa.c we do
not try to make the DT code allocate and fit within the platform data, but that
could be an option if deemed necessary.

This was tested against a "loopback" driver which is available here, and which
was built as a module and into the kernel, modprobe & rmmod were succesful and
working:

https://github.com/ffainelli/linux/blob/27024f4c9b43cf879348baa5445763c690fbc618/drivers/net/dsa/dsa_loop.c

in two configurations:

- first configuration has 4 switches connected in a cascade [1]
- second configuration is the actual binding example [2]

[1]:
https://github.com/ffainelli/linux/commit/0aa1e98c027e8e41ed2f83825da82a3d8a1c3ae2
[2]:
https://github.com/ffainelli/linux/commit/27024f4c9b43cf879348baa5445763c690fbc618

Florian Fainelli (6):
  net: dsa: Pass device pointer to dsa_register_switch
  net: dsa: Make most functions take a dsa_port argument
  net: dsa: Suffix function manipulating device_node with _dn
  net: dsa: Move ports assignment closer to error checking
  net: dsa: Export dev_to_net_device()
  net: dsa: Add support for platform data

 drivers/net/dsa/b53/b53_common.c  |   2 +-
 drivers/net/dsa/mv88e6xxx/chip.c  |   7 +-
 include/linux/platform_data/dsa.h |  61 +++++++++++
 include/net/dsa.h                 |  10 +-
 net/dsa/Kconfig                   |   1 +
 net/dsa/dsa.c                     |  58 ++++++----
 net/dsa/dsa2.c                    | 216 ++++++++++++++++++++++++++++----------
 net/dsa/dsa_priv.h                |   4 +-
 8 files changed, 273 insertions(+), 86 deletions(-)
 create mode 100644 include/linux/platform_data/dsa.h

-- 
2.7.4
