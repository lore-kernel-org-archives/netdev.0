From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 0/8] CAIF: Bugfixes and updates
Date: Thu, 20 May 2010 09:44:00 +0200
Message-ID: <1274341448-14924-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: marcel@holtmann.org, daniel.martensson@stericsson.com,
	linus.walleji@stericsson.com, sjurbren@gmail.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from thalia-smout.broadpark.no ([80.202.8.21]:51603 "EHLO
	thalia-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753119Ab0ETHom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 03:44:42 -0400
Received: from ignis-smin.broadpark.no ([unknown] [80.202.8.11])
 by thalia-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L2P00CC2K606ZD0@thalia-smout.broadpark.no> for
 netdev@vger.kernel.org; Thu, 20 May 2010 09:44:24 +0200 (CEST)
Received: from localhost.localdomain ([unknown] [84.49.77.207])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L2P008F5K603V20@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Thu, 20 May 2010 09:44:24 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Braendeland <sjur.brandeland@stericsson.com>

Hi Dave,
I have a series of CAIF bug fixes and changes. I realize you sent
the pull request to linux-next yesterday, am I too late for the
merge window with functional changes?

=46unctional changes:
o Add debug connection type for CAIF - this adds a new CAIF debug proto=
col.
o Add support for MSG_TRUNC - changes handling in seqpkt_recvmsg when=20
  user buffer cannot hold content of SKB. We are now supporting MSG_TRU=
NC
  properly.
o Use link layer MTU instead of fixed MTU - get mtu and head/tail room =
from
  CAIF Link Layer when calculating MTU in CAIF IP Interface and
  CAIF Socket Layer.

The rest are bug fixes.

Regards
Sjur Br=C3=A6ndeland

Sjur Braendeland (8):
  caif: Bugfix wait_ev*_timeout returns long.
  caif: Bugfix - use standard Linux lists
  caif: Bugfix - handle mem-allocation failures
  caif: Add support for MSG_TRUNC.
  caif: Add debug connection type for CAIF.
  caif: Use link layer MTU instead of fixed MTU
  caif: Bugfix - Poll can't return POLLHUP while connecting.
  caif: Fixed splint warnings

 drivers/net/caif/caif_serial.c   |    2 +-
 include/linux/caif/caif_socket.h |   40 ++++++++++-
 include/net/caif/caif_dev.h      |    8 ++-
 include/net/caif/caif_layer.h    |    6 --
 include/net/caif/cfcnfg.h        |   16 +++-
 include/net/caif/cfctrl.h        |    4 +-
 net/caif/caif_config_util.c      |    5 ++
 net/caif/caif_dev.c              |   12 ++-
 net/caif/caif_socket.c           |  144 ++++++++++++++++++------------=
--------
 net/caif/cfcnfg.c                |   39 ++++++++++-
 net/caif/cfctrl.c                |   93 +++++++------------------
 net/caif/cfmuxl.c                |    3 +-
 net/caif/cfpkt_skbuff.c          |   29 +++++---
 net/caif/cfrfml.c                |    5 --
 net/caif/cfserl.c                |   10 ++-
 net/caif/cfsrvl.c                |    6 ++
 net/caif/cfutill.c               |    6 --
 net/caif/cfveil.c                |    5 --
 net/caif/chnl_net.c              |   61 +++++++++++++---
 19 files changed, 284 insertions(+), 210 deletions(-)

