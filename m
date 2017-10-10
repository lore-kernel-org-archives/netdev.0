From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net 0/2] nfp: fix ethtool stats and page allocation
Date: Tue, 10 Oct 2017 09:16:21 -0700
Message-ID: <20171010161623.23838-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:55066 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932089AbdJJQQe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 12:16:34 -0400
Received: by mail-pf0-f175.google.com with SMTP id m28so12793243pfi.11
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 09:16:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

Two fixes for net.  First one makes sure we handle gather of stats on
32bit machines correctly (ouch).  The second fix solves a potential
NULL-deref if we fail to allocate a page with XDP running.

I used Fixes: tags pointing to where the bug was introduced, but for
patch 1 it has been in the driver "for ever" and fix won't backport
cleanly beyond commit 325945ede6d4 ("nfp: split software and hardware 
vNIC statistics") which is in net.


Jakub Kicinski (2):
  nfp: fix ethtool stats gather retry
  nfp: handle page allocation failures

 drivers/net/ethernet/netronome/nfp/nfp_net_common.c  | 20 ++++++++++++++------
 drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c |  8 +++++---
 2 files changed, 19 insertions(+), 9 deletions(-)

-- 
2.14.1
