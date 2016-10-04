From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH v2 net-next 0/7] xen-netback: guest rx side refactor
Date: Tue, 4 Oct 2016 10:29:11 +0100
Message-ID: <1475573358-32414-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:54781 "EHLO
        SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752757AbcJDJtG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 05:49:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series refactors the guest rx side of xen-netback:

- The code is moved into its own source module.

- The prefix variant of GSO handling is retired (since it is no longer
  in common use, and alternatives exist).

- The code is then simplified and modifications made to improve
  performance.

v2:
- Rebased onto refreshed net-next

David Vrabel (4):
  xen-netback: refactor guest rx
  xen-netback: immediately wake tx queue when guest rx queue has space
  xen-netback: process guest rx packets in batches
  xen-netback: batch copies for multiple to-guest rx packets

Paul Durrant (2):
  xen-netback: separate guest side rx code into separate module
  xen-netback: retire guest rx side prefix GSO feature

Ross Lagerwall (1):
  xen/netback: add fraglist support for to-guest rx

 drivers/net/xen-netback/Makefile    |   2 +-
 drivers/net/xen-netback/common.h    |  25 +-
 drivers/net/xen-netback/interface.c |   6 +-
 drivers/net/xen-netback/netback.c   | 754 ------------------------------------
 drivers/net/xen-netback/rx.c        | 628 ++++++++++++++++++++++++++++++
 drivers/net/xen-netback/xenbus.c    |  21 -
 6 files changed, 643 insertions(+), 793 deletions(-)
 create mode 100644 drivers/net/xen-netback/rx.c

-- 
2.1.4
