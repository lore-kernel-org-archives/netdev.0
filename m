From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH next 0/3] re-org actor admin/oper key updates
Date: Sat, 31 Oct 2015 12:44:55 -0700
Message-ID: <1446320695-38570-1-git-send-email-maheshb@google.com>
Cc: Mahesh Bandewar <maheshb@google.com>,
	David Decotigny <decot@google.com>,
	netdev <netdev@vger.kernel.org>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35098 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887AbbJaTpA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Oct 2015 15:45:00 -0400
Received: by pasz6 with SMTP id z6so106009060pas.2
        for <netdev@vger.kernel.org>; Sat, 31 Oct 2015 12:45:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was observing machines entering into weird LACP state when the
partner is in passive mode. This issue is not because of the partners
in passive state but probably because of some operational key update
which is pushing the state-machine is that weird state. This was
happening randomly on about 1% of the machine (when the sample size
is a large set of machines with a variety of NICs/ports bonded).

In this patch-series I'm attempting to unify the logic of actor-key
/ operational-key changes to one place to avoid possible errors in
update. Also this eliminates the need for the event-handler to decide
if the key needs update.

After this patch-set none of the machines (from same sample set) were
exhibiting LACP-weirdness that was observed earlier.

Mahesh Bandewar (3):
  bonding: Simplify __get_duplex function.
  bonding: unify all places where actor-oper key needs to be updated.
  bonding: simplify / unify event handling code for 3ad mode.

 drivers/net/bonding/bond_3ad.c  | 113 ++++++++++++++++++----------------------
 drivers/net/bonding/bond_main.c |  14 +----
 include/net/bond_3ad.h          |   3 +-
 3 files changed, 54 insertions(+), 76 deletions(-)

-- 
2.6.0.rc2.230.g3dd15c0
