From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH iproute2 0/3] ip-link: XDP flags and offload mode
Date: Mon, 26 Jun 2017 17:23:50 -0700
Message-ID: <20170627002353.12292-1-jakub.kicinski@netronome.com>
Cc: daniel@iogearbox.net, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:34991 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751454AbdF0AYC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2017 20:24:02 -0400
Received: by mail-pf0-f182.google.com with SMTP id c73so7786238pfk.2
        for <netdev@vger.kernel.org>; Mon, 26 Jun 2017 17:24:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This series adds support for specifying DRV_MODE and new HW_MODE
flags when binding an XDP program to the driver.  It also teaches
ip link about "xdpoffload" attachment mode.

Examples:
# ip link set dev p4p1 xdpoffload obj prog.o sec '.text'
# ip link show dev p4p1
60: p4p1: <BROADCAST,MULTICAST> mtu 1500 xdpoffload/id:2 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 00:15:4d:12:27:6b brd ff:ff:ff:ff:ff:ff
# ip link set dev p4p1 xdpoffload off

Note: this is based on top of Martin's "bpf: Add support for 
IFLA_XDP_PROG_ID".

Jakub Kicinski (3):
  bpf: print xdp offloaded mode
  bpf: add xdpdrv for requesting XDP driver mode
  bpf: allow requesting XDP HW offload

 include/linux/if_link.h |  2 ++
 ip/iplink.c             |  7 ++++++-
 ip/iplink_xdp.c         |  9 ++++++++-
 ip/xdp.h                |  3 ++-
 man/man8/ip-link.8.in   | 13 ++++++++++++-
 5 files changed, 30 insertions(+), 4 deletions(-)

-- 
2.11.0
