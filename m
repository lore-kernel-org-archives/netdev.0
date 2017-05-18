From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH net 0/3] vlan: Offload fixes for Q-in-Q vlans
Date: Thu, 18 May 2017 09:31:02 -0400
Message-ID: <1495114265-23368-1-git-send-email-vyasevic@redhat.com>
Cc: Vladislav Yasevich <vyasevic@redhat.com>,
        Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:35495 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755071AbdERNbZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 09:31:25 -0400
Received: by mail-qk0-f195.google.com with SMTP id k74so6014089qke.2
        for <netdev@vger.kernel.org>; Thu, 18 May 2017 06:31:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the following commit:

commit 8cb65d00086bfba22bac87ff18b751432fc74003
Author: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Date:   Fri Mar 27 14:31:12 2015 +0900

    net: Move check for multiple vlans to drivers

offloads were broken in Q-in-Q vlans. The biggest problem was
that tcp checksum offload was enabled and used for all hardware,
while most of the supported HW (mostly old HW and some newer ones)
don't support it.  As a result, tcp connections could not be
established when using Q-in-Q vlans.

This short series corrects this by disabling checksum offload
support on packets sent through Q-in-Q vlans.  It is up to individual
drivers to enable it properly through ndo_features_check if they
have some support for Q-in-Q vlans.


Vladislav Yasevich (3):
  vlan: Fix Q-in-Q vlan support.
  be2net: Fix offload features for Q-in-Q packets
  virtio-net: enable TSO/checksum offloads for Q-in-Q vlans

 drivers/net/ethernet/emulex/benet/be_main.c | 4 +++-
 drivers/net/virtio_net.c                    | 1 +
 include/linux/if_vlan.h                     | 1 -
 3 files changed, 4 insertions(+), 2 deletions(-)

CC: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
-- 
2.7.4
