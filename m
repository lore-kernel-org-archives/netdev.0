From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC net-next 0/9] introduce flower offload capabilities
Date: Wed, 28 Jun 2017 01:21:40 +0200
Message-ID: <1498605709-22574-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:33494 "EHLO
        mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752792AbdF0XWK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 19:22:10 -0400
Received: by mail-qk0-f174.google.com with SMTP id r62so38340118qkf.0
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 16:22:10 -0700 (PDT)
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
 drivers/net/ethernet/netronome/nfp/flower/action.c | 210 +++++++++
 drivers/net/ethernet/netronome/nfp/flower/cmsg.c   |  11 +-
 drivers/net/ethernet/netronome/nfp/flower/cmsg.h   | 202 ++++++++
 drivers/net/ethernet/netronome/nfp/flower/main.c   |  17 +-
 drivers/net/ethernet/netronome/nfp/flower/main.h   | 161 +++++++
 drivers/net/ethernet/netronome/nfp/flower/match.c  | 292 ++++++++++++
 .../net/ethernet/netronome/nfp/flower/metadata.c   | 518 +++++++++++++++++++++
 .../net/ethernet/netronome/nfp/flower/offload.c    | 417 +++++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |   1 +
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |   3 +
 drivers/net/ethernet/netronome/nfp/nfp_net_repr.c  |  20 +
 drivers/net/ethernet/netronome/nfp/nfp_net_repr.h  |  10 +-
 drivers/net/ethernet/netronome/nfp/nfp_port.c      |  28 ++
 drivers/net/ethernet/netronome/nfp/nfp_port.h      |   3 +
 include/net/switchdev.h                            |   4 +
 16 files changed, 1887 insertions(+), 16 deletions(-)
 create mode 100644 drivers/net/ethernet/netronome/nfp/flower/action.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/flower/main.h
 create mode 100644 drivers/net/ethernet/netronome/nfp/flower/match.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/flower/metadata.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/flower/offload.c

-- 
2.1.4
