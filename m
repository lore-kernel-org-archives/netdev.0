From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next v2 0/4] packet: add cBPF and eBPF fanout modes
Date: Fri, 14 Aug 2015 22:31:33 -0400
Message-ID: <1439605897-28311-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, edumazet@google.com, daniel@iogearbox.net,
	ast@plumgrid.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:35941 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752113AbbHOCbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 22:31:41 -0400
Received: by qgdd90 with SMTP id d90so63281639qgd.3
        for <netdev@vger.kernel.org>; Fri, 14 Aug 2015 19:31:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Allow programmable fanout modes. Support both classical BPF programs
passed directly and extended BPF programs passed by file descriptor.

One use case is packet steering by deep packet inspection, for
instance for packet steering by application layer header fields.

Separate the configuration of the fanout mode and the configuration
of the program, to allow dynamic updates to the latter at runtime.

Changes
  v1 -> v2:
    - follow SO_LOCK_FILTER semantics on filter updates
    - only accept eBPF programs of type BPF_PROG_TYPE_SOCKET_FILTER
    - rename PACKET_FANOUT_BPF to PACKET_FANOUT_CBPF to match
      man 2 bpf usage: "classic" vs. "extended" BPF.

Willem de Bruijn (4):
  packet: add classic BPF fanout mode
  packet: add extended BPF fanout mode
  selftests/net: test classic bpf fanout mode
  selftests/net: test extended BPF fanout mode

 include/uapi/linux/if_packet.h             |   3 +
 net/packet/af_packet.c                     | 130 ++++++++++++++++++++++++++++-
 net/packet/internal.h                      |   5 +-
 tools/testing/selftests/net/psock_fanout.c |  69 ++++++++++++++-
 tools/testing/selftests/net/psock_lib.h    |  29 +++++--
 5 files changed, 222 insertions(+), 14 deletions(-)

-- 
2.5.0.276.gf5e568e
