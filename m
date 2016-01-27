From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [RFC PATCH net-next 0/3] sctp: add GSO support
Date: Wed, 27 Jan 2016 15:06:30 -0200
Message-ID: <cover.1453913331.git.marcelo.leitner@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>, brouer@redhat.com,
	alexander.duyck@gmail.com, alexei.starovoitov@gmail.com,
	borkmann@iogearbox.net, marek@cloudflare.com,
	hannes@stressinduktion.org, fw@strlen.de, pabeni@redhat.com,
	john.r.fastabend@intel.com, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50860 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752976AbcA0RGv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jan 2016 12:06:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is merely a RFC for the moment. There are some
controversial points that I'd like to discuss before actually proposing
the patches.

The points are more detailed in the 3rd patch.

Another approach that I can think of, is using something related to
what Dave Miller mentioned on the thread 'Optimizing instruction-cache,
more packets at each stage' about skb bundling, so I Cc'ed people from
that thread too.
SCTP could generate a list of related skbs, after all that's pretty much
what this patchset does but using GRO/GSO infrastructure that is already
there.

PS: I also have code for GRO on top of this patchset, but it needs more
work yet.

Thanks!

Marcelo Ricardo Leitner (3):
  skbuff: export skb_gro_receive
  sctp: offloading support structure
  sctp: Add GSO support

 include/linux/netdev_features.h |   7 +-
 include/linux/netdevice.h       |   1 +
 include/linux/skbuff.h          |   2 +
 include/net/sctp/sctp.h         |   4 +
 net/core/dev.c                  |   6 +-
 net/core/skbuff.c               |  13 +-
 net/ipv4/af_inet.c              |   1 +
 net/sctp/Makefile               |   3 +-
 net/sctp/offload.c              | 100 ++++++++++++
 net/sctp/output.c               | 338 +++++++++++++++++++++++++---------------
 net/sctp/protocol.c             |   3 +
 net/sctp/socket.c               |   2 +
 12 files changed, 351 insertions(+), 129 deletions(-)
 create mode 100644 net/sctp/offload.c

-- 
2.5.0
