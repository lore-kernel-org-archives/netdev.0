From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC net-next 0/8] xdp: offload mode
Date: Fri, 16 Jun 2017 16:57:38 -0700
Message-ID: <20170616235746.16337-1-jakub.kicinski@netronome.com>
Cc: davem@davemloft.net, kafai@fb.com, daniel@iogearbox.net,
        netoptimizer@brouer.com, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:36129 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750967AbdFPX6Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 19:58:24 -0400
Received: by mail-pg0-f49.google.com with SMTP id u62so7096577pgb.3
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 16:58:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This set adds XDP flag for forcing offload and a attachement mode
for reporting to user space that program has been offloaded.  The
nfp driver is modified to make use of the new flags, but also to
adhere to the DRV_MODE flag which should disable the HW offload.

Note that the NFP driver currently claims XDP offload support but 
lacks most basic features like direct packet access.

Jakub Kicinski (8):
  xdp: pass XDP flags into install handlers
  xdp: add HW offload mode flag for installing programs
  nfp: xdp: move driver XDP setup into a separate function
  nfp: bpf: don't offload XDP programs in DRV_MODE
  nfp: bpf: take a reference on offloaded programs
  nfp: bpf: add support for XDP_FLAGS_HW_MODE
  xdp: add reporting of offload mode
  nfp: xdp: report if program is offloaded

 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  5 ++
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 53 ++++++++++++++++------
 include/linux/netdevice.h                          |  8 ++--
 include/uapi/linux/if_link.h                       |  8 +++-
 net/core/dev.c                                     | 10 ++--
 net/core/rtnetlink.c                               | 10 ++--
 6 files changed, 66 insertions(+), 28 deletions(-)

-- 
2.11.0
