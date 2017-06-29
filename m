From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next v3 0/9] introduce flower offload capabilities
Date: Thu, 29 Jun 2017 22:08:10 +0200
Message-ID: <1498766899-30707-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Or Gerlitz <gerlitz.or@gmail.com>,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f179.google.com ([209.85.216.179]:35514 "EHLO
        mail-qt0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751612AbdF2UIl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 16:08:41 -0400
Received: by mail-qt0-f179.google.com with SMTP id f92so83564948qtb.2
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 13:08:41 -0700 (PDT)
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

Key Changes since v2:
* Revised flow structures to simplify setup/teardown and locking of stats
* Addressed other code-change review of v2

Other review questions regarding v2 have been answered on netdev.


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
 drivers/net/ethernet/netronome/nfp/flower/action.c | 211 ++++++++++
 drivers/net/ethernet/netronome/nfp/flower/cmsg.c   |  11 +-
 drivers/net/ethernet/netronome/nfp/flower/cmsg.h   | 201 ++++++++++
 drivers/net/ethernet/netronome/nfp/flower/main.c   |  39 +-
 drivers/net/ethernet/netronome/nfp/flower/main.h   | 159 ++++++++
 drivers/net/ethernet/netronome/nfp/flower/match.c  | 292 ++++++++++++++
 .../net/ethernet/netronome/nfp/flower/metadata.c   | 438 +++++++++++++++++++++
 .../net/ethernet/netronome/nfp/flower/offload.c    | 400 +++++++++++++++++++
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |  17 +-
 drivers/net/ethernet/netronome/nfp/nfp_net_repr.c  |   8 +
 drivers/net/ethernet/netronome/nfp/nfp_net_repr.h  |   9 +
 drivers/net/ethernet/netronome/nfp/nfp_port.c      |  44 +++
 drivers/net/ethernet/netronome/nfp/nfp_port.h      |   6 +
 include/net/switchdev.h                            |   4 +
 15 files changed, 1816 insertions(+), 29 deletions(-)
 create mode 100644 drivers/net/ethernet/netronome/nfp/flower/action.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/flower/main.h
 create mode 100644 drivers/net/ethernet/netronome/nfp/flower/match.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/flower/metadata.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/flower/offload.c

-- 
2.1.4
