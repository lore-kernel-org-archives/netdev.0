From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH V2 net 0/4] macvlan: Fix some issues with changing mac addresses
Date: Wed, 21 Jun 2017 07:59:15 -0400
Message-ID: <20170621115919.28165-1-vyasevic@redhat.com>
Cc: girish.moodalbail@oracle.com,
        Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f176.google.com ([209.85.216.176]:36137 "EHLO
        mail-qt0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750823AbdFUL73 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 07:59:29 -0400
Received: by mail-qt0-f176.google.com with SMTP id i2so7032987qta.3
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 04:59:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are some issues in macvlan wrt to changing it's mac address.
* An error is returned in the specified address is the same as an already
  assigned address.
* In passthru mode, the mac address of the macvlan device doesn't change.
* After changing the mac address of a passthru macvlan and then removing it,
  the mac address of the physical device remains changed.

This patch series attempts to resolve these issues.

V2: Address a small issue in p4 where we save the address from the lowerdev
    (from girish.moodalbail@oracle.com)

Thanks
-vlad

Vladislav Yasevich (4):
  macvlan: Do not return error when setting the same mac address
  macvlan: Fix passthru macvlan mac address inheritance
  macvlan: convert port passthru to flags.
  macvlan: Let passthru macvlan correctly restore lower mac address

 drivers/net/macvlan.c | 85 ++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 71 insertions(+), 14 deletions(-)

-- 
2.9.4
