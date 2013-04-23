From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/5] PF_PACKET timestamping updates
Date: Tue, 23 Apr 2013 12:39:27 +0200
Message-ID: <1366713572-11978-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, willemb@google.com, Paul.Chavent@onera.fr,
	richardcochran@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21992 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755735Ab3DWKkt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Apr 2013 06:40:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a joint effort with Willem to bring optional i) tx hw/sw
timestamping into PF_PACKET, that was reported by Paul Chavent,
and ii) to expose the type of timestamp to the user, which is in
the current situation not possible to distinguish with the RX_RING
and TX_RING API (but distinguishable through the normal timestamping
API), reported by Richard Cochran. This set is based on top of
``packet: account statistics only in tpacket_stats_u''. Related
discussion can be found in: http://patchwork.ozlabs.org/patch/238125/

Daniel Borkmann (4):
  packet: enable hardware tx timestamping on tpacket ring
  packet: minor: convert status bits into shifting format
  packet: if hw/sw ts enabled in rx/tx ring, report which ts we got
  packet: doc: update timestamping part

Willem de Bruijn (1):
  packet: tx timestamping on tpacket ring

 Documentation/networking/packet_mmap.txt | 41 ++++++++++++---
 include/uapi/linux/if_packet.h           | 27 ++++++----
 net/core/skbuff.c                        | 12 ++---
 net/packet/af_packet.c                   | 87 ++++++++++++++++++++++++--------
 4 files changed, 122 insertions(+), 45 deletions(-)

-- 
1.7.11.7
