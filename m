From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2 0/6] nfp: devlink port implementation
Date: Fri, 26 May 2017 01:03:30 -0700
Message-ID: <20170526080336.32689-1-jakub.kicinski@netronome.com>
Cc: jiri@resnulli.us, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35121 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932725AbdEZIDw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 04:03:52 -0400
Received: by mail-pf0-f175.google.com with SMTP id n23so4724798pfb.2
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 01:03:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This series adds basic devlink support.  The operations we can perform
are port show and port split/unsplit.

v2:
Register devlink first, and then register all the ports.  Port {,un}split
searches the port list, which is protected by a mutex.  If port split
is requested before ports are registered we will simply not find the port
and return -EINVAL.

Jakub Kicinski (5):
  nfp: move mutex init out of net code
  nfp: add helper for cleaning up vNICs
  nfp: register ports as devlink ports
  nfp: calculate total port lanes for split
  nfp: support port splitting via devlink

Simon Horman (1):
  nfp: add devlink support

 drivers/net/ethernet/netronome/nfp/Makefile        |   1 +
 drivers/net/ethernet/netronome/nfp/nfp_devlink.c   | 181 +++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_main.c      |  28 +++-
 drivers/net/ethernet/netronome/nfp/nfp_main.h      |   3 +
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c  |  61 ++++---
 drivers/net/ethernet/netronome/nfp/nfp_port.c      |  19 +++
 drivers/net/ethernet/netronome/nfp/nfp_port.h      |  12 ++
 .../net/ethernet/netronome/nfp/nfpcore/nfp_nsp.h   |   3 +
 .../ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c   |  11 +-
 9 files changed, 289 insertions(+), 30 deletions(-)
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_devlink.c

-- 
2.11.0
