From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next 0/5] bonding: winter cleanup
Date: Wed,  8 Mar 2017 10:55:45 -0800
Message-ID: <20170308185545.22864-1-mahesh@bandewar.net>
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
Received: from mail-pf0-f195.google.com ([209.85.192.195]:32873 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752094AbdCHTbb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 14:31:31 -0500
Received: by mail-pf0-f195.google.com with SMTP id v190so4727268pfb.0
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 11:30:17 -0800 (PST)
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

(d) Reduce scope of some global variables to local.

Note: None of these patches are making any functional changes.

Mahesh Bandewar (5):
  bonding: restructure arp-monitor
  bonding: initialize work-queues during creation of bond
  bonding: remove hardcoded value
  bonding: remove "port-moved" state that was never implemented
  bonding: reduce scope of some global variables

 drivers/net/bonding/bond_3ad.c  | 11 +++------
 drivers/net/bonding/bond_main.c | 53 ++++++++++++++++++++++++++---------------
 2 files changed, 37 insertions(+), 27 deletions(-)

-- 
2.12.0.246.ga2ecc84866-goog
