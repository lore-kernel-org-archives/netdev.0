From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next v2 0/9] introduce flower offload capabilities
Date: Wed, 28 Jun 2017 22:29:53 +0200
Message-ID: <1498681802-2897-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f171.google.com ([209.85.216.171]:36464 "EHLO
        mail-qt0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752142AbdF1Ubj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 16:31:39 -0400
Received: by mail-qt0-f171.google.com with SMTP id i2so59321175qta.3
        for <netdev@vger.kernel.org>; Wed, 28 Jun 2017 13:31:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this series adds flower offload to the NFP driver. It builds on recent
work to add representor and a skeleton flower app - now the app does what
its name says.

In general the approach taken is to allow some flows within
the universe of possible flower matches and tc actions to be offloaded.
It is planned that this support will grow over time but the support
offered by this patch-set seems to be a reasonable starting point.

Key Changes since RFC:
* Revised locking scheme for flows
* Make generalise tc_setup NDO
* Addressed other review of RFC
* Dropped RFC designation

Pieter Jansen van Vuuren (7):
  nfp: provide infrastructure for offloading flower based TC filters
  nfp: extend flower add flow offload
  nfp: extend flower matching capabilities
  nfp: add basic action capabilities to flower offloads
  nfp: add metadata to each flow offload
  nfp: add a stats handler for flower offloads
  nfp: add control message passing capabilities to flower offloads

Simon Horman (2):
  net: switchdev: add SET_SWITCHDEV_OPS helper
  nfp: add phys_switch_id support

 drivers/net/ethernet/netronome/nfp/Makefile        |   6 +-
 drivers/net/ethernet/netronome/nfp/flower/action.c | 211 +++++++++
 drivers/net/ethernet/netronome/nfp/flower/cmsg.c   |  11 +-
 drivers/net/ethernet/netronome/nfp/flower/cmsg.h   | 202 +++++++++
 drivers/net/ethernet/netronome/nfp/flower/main.c   |  32 +-
 drivers/net/ethernet/netronome/nfp/flower/main.h   | 159 +++++++
 drivers/net/ethernet/netronome/nfp/flower/match.c  | 292 ++++++++++++
 .../net/ethernet/netronome/nfp/flower/metadata.c   | 497 +++++++++++++++++++++
 .../net/ethernet/netronome/nfp/flower/offload.c    | 397 ++++++++++++++++
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |  17 +-
 drivers/net/ethernet/netronome/nfp/nfp_net_repr.c  |   8 +
 drivers/net/ethernet/netronome/nfp/nfp_net_repr.h  |   9 +
 drivers/net/ethernet/netronome/nfp/nfp_port.c      |  43 ++
 drivers/net/ethernet/netronome/nfp/nfp_port.h      |   8 +
 include/net/switchdev.h                            |   4 +
 15 files changed, 1869 insertions(+), 27 deletions(-)
 create mode 100644 drivers/net/ethernet/netronome/nfp/flower/action.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/flower/main.h
 create mode 100644 drivers/net/ethernet/netronome/nfp/flower/match.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/flower/metadata.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/flower/offload.c

-- 
2.1.4
