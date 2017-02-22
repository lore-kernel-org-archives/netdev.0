From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next 0/4] bonding: winter cleanup
Date: Tue, 21 Feb 2017 17:08:16 -0800
Message-ID: <20170222010816.9676-1-mahesh@bandewar.net>
Cc: netdev <netdev@vger.kernel.org>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Mahesh Bandewar <maheshb@google.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Veaceslav Falico <vfalico@gmail.com>,
        Nikolay Aleksandrov <nikolay@redhat.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33074 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753301AbdBVBIX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 20:08:23 -0500
Received: by mail-pg0-f65.google.com with SMTP id 5so20834938pgj.0
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 17:08:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

Few cleanup patches that I have accumulated over some time now.

(a) First two patches are basically to move the work-queue initialization
    from every ndo_open / bond_open operation to once at the beginning while
    port creation. Work-queue initialization is an unnecessary operation
    for every 'ifup' operation. However we have some mode-specific work-queues
    and mode can change anytime after port creation. So the second patch is
    to ensure the correct work-handler is called based on the mode.

(b) Third patch is simple and straightforward that removes hard-coded value
    that was added into the initial commit and replaces it with the default
    value configured.

(c) The final patch in the series removes the unimplemented "port-moved" state
    from the LACP state machine. This state is defined but never set so
    removing from the state machine logic makes code little cleaner.

Note: None of these patches are making any functional changes.

Mahesh Bandewar (4):
  bonding: restructure arp-monitor
  bonding: initialize work-queues during creation of bond
  bonding: remove hardcoded value
  bonding: remove "port-moved" state that was never implemented

 drivers/net/bonding/bond_3ad.c  | 11 +++--------
 drivers/net/bonding/bond_main.c | 42 ++++++++++++++++++++++++++++-------------
 2 files changed, 32 insertions(+), 21 deletions(-)

-- 
2.11.0.483.g087da7b7c-goog
