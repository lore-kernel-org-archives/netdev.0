From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH net 0/4] macvlan: Fix some issues with changing mac addresses
Date: Fri, 16 Jun 2017 09:36:45 -0400
Message-ID: <20170616133649.24622-1-vyasevic@redhat.com>
Cc: Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f175.google.com ([209.85.216.175]:34337 "EHLO
        mail-qt0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753441AbdFPNg6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 09:36:58 -0400
Received: by mail-qt0-f175.google.com with SMTP id c10so63398073qtd.1
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 06:36:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are some issues in macvlan wrt to changing it's mac address.
* An error is returned in the specified address is the same as an already
  assigned address.
* In passthru mode, the mac address of the macvlan device doesn't change.
* After changing the mac address of a passthru macvlan and then removing it,
  the mac address of the physical device remains changed.

This patch series attempts to resolve these issues.

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
