From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 0/2] rx zero copy interface for af_packet
Date: Fri, 27 Jan 2017 13:33:20 -0800
Message-ID: <20170127213132.14162.82951.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com
To: bjorn.topel@gmail.com, jasowang@redhat.com, ast@fb.com,
        alexander.duyck@gmail.com, brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34531 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751180AbdA0Vdh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 16:33:37 -0500
Received: by mail-pf0-f195.google.com with SMTP id y143so19272150pfb.1
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 13:33:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an experimental implementation of rx zero copy for af_packet.
Its a bit rough and likely has errors but the plan is to clean it up
over the next few months.

And seeing I said I would post it in another thread a few days back
here it is.

Comments welcome and use at your own risk.

Thanks,
John


---

John Fastabend (2):
      af_packet: direct dma for packet ineterface
      ixgbe: add af_packet direct copy support


 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    3 
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  255 +++++++++++++++++++++++++
 include/linux/netdevice.h                     |    8 +
 include/net/af_packet.h                       |   64 ++++++
 include/uapi/linux/if_packet.h                |    1 
 net/packet/af_packet.c                        |   37 ++++
 net/packet/internal.h                         |   60 ------
 tools/testing/selftests/net/psock_tpacket.c   |   51 ++++-
 8 files changed, 410 insertions(+), 69 deletions(-)
 create mode 100644 include/net/af_packet.h
