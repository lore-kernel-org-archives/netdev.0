From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 0/4] net: switchdev: Avoid sleep in atomic with DSA
Date: Mon,  9 Jan 2017 12:45:19 -0800
Message-ID: <20170109204523.5843-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, jiri@resnulli.us, marcelo.leitner@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36642 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754754AbdAIUp0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 15:45:26 -0500
Received: by mail-pf0-f195.google.com with SMTP id b22so8866401pfd.3
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 12:45:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series is to resolve a sleeping function called in atomic context
debug splat that we observe with DSA.

Let me know what you think, I was also wondering if we should just always
make switchdev_port_vlan_fill() set SWITCHDEV_F_DEFER, but was afraid this
could cause invalid contexts to be used for rocker, mlxsw, i40e etc.

Changes in v2:

- Make patch 3 actually build, thanks to Marcelo for reporting the
  problem

Thanks!

Florian Fainelli (4):
  net: switchdev: Prepare for deferred functions modifying objects
  net: switchdev: Add object dump deferred operation
  net: switchdev: Add switchdev_port_bridge_getlink_deferred
  net: dsa: Utilize switchdev_port_bridge_getlink_deferred()

 include/net/switchdev.h   |   3 +
 net/dsa/slave.c           |   2 +-
 net/switchdev/switchdev.c | 171 +++++++++++++++++++++++++++++++++++++---------
 3 files changed, 141 insertions(+), 35 deletions(-)

-- 
2.9.3
