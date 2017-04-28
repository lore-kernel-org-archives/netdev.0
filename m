From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 0/6] nfp: optimize XDP TX and small fixes
Date: Thu, 27 Apr 2017 21:06:14 -0700
Message-ID: <20170428040620.8256-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:35625 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751178AbdD1EG5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 00:06:57 -0400
Received: by mail-pg0-f48.google.com with SMTP id o3so3017646pgn.2
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 21:06:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This series optimizes the nfp XDP TX performance a little bit.  
I run quick tests on an Intel(R) Xeon(R) CPU E5-2630 v4 @ 2.20GHz.  
Single core/queue performance for both touch and drop and touch and
forward is above 20Mpps @64B packets, drop being 2Mpps faster.  
I think this is max for a single queue on the low power NFPs.

There are also a few minor fixes included for code in net-next.

Jakub Kicinski (6):
  nfp: replace -ENOTSUPP with -EOPNOTSUPP
  nfp: drop rx_ring param from buffer allocation
  nfp: do simple XDP TX buffer recycling
  nfp: avoid reading TX queue indexes from the device
  nfp: don't completely refuse to work with old flashes
  nfp: provide 256 bytes of XDP headroom in all configurations

 drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c   |  24 +--
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |   6 +-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 171 +++++++++++----------
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |   2 +-
 .../net/ethernet/netronome/nfp/nfp_net_offload.c   |  12 +-
 .../net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c   |   4 +-
 6 files changed, 118 insertions(+), 101 deletions(-)

-- 
2.11.0
