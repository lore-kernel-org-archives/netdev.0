From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 0/4] ip_tunnel: add collect_md mode to IPv4/IPv6 tunnels
Date: Thu, 15 Sep 2016 13:00:28 -0700
Message-ID: <1473969632-2408261-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Thomas Graf <tgraf@suug.ch>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:45537 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754283AbcIOUAg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 16:00:36 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8FJxV4q006967
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 13:00:35 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 25g21kr3p8-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 13:00:35 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.223.100.99) with ESMTP id
 0f948c067b7f11e6b2fd24be05956610-7c2e5a50 for <netdev@vger.kernel.org>;        Thu,
 15 Sep 2016 13:00:33 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to geneve, vxlan, gre tunnels implement 'collect metadata' mode
in ipip, ipip6, ip6ip6 tunnels.

Alexei Starovoitov (4):
  ip_tunnel: add collect_md mode to IPIP tunnel
  ip6_tunnel: add collect_md mode to IPv6 tunnels
  samples/bpf: extend test_tunnel_bpf.sh with IPIP test
  samples/bpf: add comprehensive ipip, ipip6, ip6ip6 test

 include/net/ip6_tunnel.h       |   1 +
 include/net/ip_tunnels.h       |   2 +
 include/uapi/linux/if_tunnel.h |   1 +
 net/ipv4/ip_tunnel.c           |  76 +++++++++++++++++
 net/ipv4/ipip.c                |  35 ++++++--
 net/ipv6/ip6_tunnel.c          | 178 ++++++++++++++++++++++++++++----------
 samples/bpf/tcbpf2_kern.c      | 190 +++++++++++++++++++++++++++++++++++++++++
 samples/bpf/test_ipip.sh       | 178 ++++++++++++++++++++++++++++++++++++++
 samples/bpf/test_tunnel_bpf.sh |  56 ++++++++++--
 9 files changed, 658 insertions(+), 59 deletions(-)
 create mode 100755 samples/bpf/test_ipip.sh

-- 
2.8.0
