From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/7] BPF updates
Date: Fri,  4 Mar 2016 15:15:01 +0100
Message-ID: <cover.1457099834.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39178 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752255AbcCDOPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 09:15:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Couple of misc updates to BPF, besides others this series adds
bpf_csum_diff() to be used with L3 csums, allows for managing
tunnel options for collect meta data mode, and enabling ipv6
traffic class for collect meta data in vxlan specifically (geneve
already supports it). For more details, please see individual
patches.

The series requires net to be merged into net-next first to
avoid any further pending merge conflicts.

Thanks a lot!

Daniel Borkmann (7):
  bpf: allow bpf_csum_diff to feed bpf_l3_csum_replace as well
  bpf: add flags to bpf_skb_store_bytes for clearing hash
  bpf: make helper function protos static
  bpf: allow to propagate df in bpf_skb_set_tunnel_key
  bpf: support for access to tunnel options
  bpf, vxlan, geneve, gre: fix usage of dst_cache on xmit
  vxlan: allow setting ipv6 traffic class

 drivers/net/geneve.c     |  10 ++--
 drivers/net/vxlan.c      |  38 ++++++++-------
 include/net/checksum.h   |   5 ++
 include/net/ip_tunnels.h |  15 ++++++
 include/uapi/linux/bpf.h |  13 ++++++
 net/core/filter.c        | 119 ++++++++++++++++++++++++++++++++++++++++-------
 net/ipv4/ip_gre.c        |  10 ++--
 7 files changed, 165 insertions(+), 45 deletions(-)

-- 
1.9.3
