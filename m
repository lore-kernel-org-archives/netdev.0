From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 00/10] bpf: xdp: Report bpf_prog ID in IFLA_XDP
Date: Mon, 12 Jun 2017 18:00:15 -0700
Message-ID: <20170613010025.2983342-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:52085 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752987AbdFMBA2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 21:00:28 -0400
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5D0xkA9001848
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 18:00:28 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2b1wwd1yqj-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 18:00:28 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (2401:db00:2050:5102:face:0000:0037:0000) with ESMTP       id
 afcfe17e4fd311e7834b798f40080b9f-d2b3d8f0 for <netdev@vger.kernel.org>;        Mon,
 12 Jun 2017 18:00:26 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the first usage of the new bpf_prog ID.  It is for
reporting the ID of a xdp_prog through netlink.

It rides on the existing IFLA_XDP.  This patch adds IFLA_XDP_PROG_ID
for the bpf_prog ID reporting.

It starts with changing the generic_xdp first.  After that,
the hardware driver is changed one by one.  The final patch
removes the prog_attached from 'struct netdev_xdp' because
prog_id > 0 implies the presence of xdp_prog.

I have tested with generic_xdp, mlx4 and mlx5.

Martin KaFai Lau (10):
  net: Add IFLA_XDP_PROG_ID
  bpf: mlx4: Report bpf_prog ID during XDP_QUERY_PROG
  bpf: mlx5e: Report bpf_prog ID during XDP_QUERY_PROG
  bpf: virtio_net: Report bpf_prog ID during XDP_QUERY_PROG
  bpf: bnxt: Report bpf_prog ID during XDP_QUERY_PROG
  bpf: thunderx: Report bpf_prog ID during XDP_QUERY_PROG
  bpf: ixgbe: Report bpf_prog ID during XDP_QUERY_PROG
  bpf: nfp: Report bpf_prog ID during XDP_QUERY_PROG
  bpf: qede: Report bpf_prog ID during XDP_QUERY_PROG
  net: Remove prog_attached from struct netdev_xdp

 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c      | 11 ++++++--
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   | 11 ++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      | 11 ++++++--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     | 20 ++++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 14 ++++++++--
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 11 ++++++--
 drivers/net/ethernet/qlogic/qede/qede_filter.c     | 11 ++++++--
 drivers/net/virtio_net.c                           | 12 ++++----
 include/linux/netdevice.h                          |  4 +--
 include/uapi/linux/if_link.h                       |  1 +
 net/core/dev.c                                     | 15 +++++-----
 net/core/rtnetlink.c                               | 32 +++++++++++++++++-----
 12 files changed, 116 insertions(+), 37 deletions(-)

-- 
2.9.3
