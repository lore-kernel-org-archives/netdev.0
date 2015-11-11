From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net v3 0/5] packet fixes
Date: Wed, 11 Nov 2015 23:25:39 +0100
Message-ID: <cover.1447278504.git.daniel@iogearbox.net>
Cc: edumazet@google.com, willemb@google.com, tklauser@distanz.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57162 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753143AbbKKWZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 17:25:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes a couple of issues in packet sockets, i.e. on TX ring side. See
individual patches for details.

v2 -> v3:
 - First two patches unchanged, kept Jason's Ack
 - Reworked 3rd patch and split into 3:
  - check for dev type as discussed with Willem
  - infer skb->protocol
  - fix max len for dgram
v1 -> v2:
 - Added patch 2 as suggested by Dave
 - Rest is unchanged from previous submission

Daniel Borkmann (5):
  packet: do skb_probe_transport_header when we actually have data
  packet: always probe for transport header
  packet: only allow extra vlan len on ethernet devices
  packet: infer protocol from ethernet header if unset
  packet: fix tpacket_snd max frame len

 net/packet/af_packet.c | 86 ++++++++++++++++++++++++++------------------------
 1 file changed, 44 insertions(+), 42 deletions(-)

-- 
1.9.3
