From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCHes] pull request: WAN
Date: Sat, 19 Jul 2008 15:04:48 +0200
Message-ID: <m3ljzyc9e7.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:55032 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753229AbYGSNEv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Jul 2008 09:04:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

Please pull from:
git://git.kernel.org/pub/scm/linux/kernel/git/chris/linux-2.6.git hdlc

This is based on pure v2.6.26 and includes various WAN cleanups as
well as LMC, Zilog (hostess_sv11 + sealevel = z85230) and Cosa drivers
ported from syncppp to generic HDLC. I have no hardware for that so -
untested.

This makes hdlc-ppp the only user of syncppp.

My plan is to replace hdlc-ppp and syncppp with the new hdlc-ppp, hope
that's now ok with syncppp going.

The long-term plan is to also add generic PPP interface so users can
do PPP auth, compression and what not. 2.6.30+ maybe.

I have tried to test-merge your upstream-next branch and it causes
conflicts in drivers/net/wan/pc300_drv.c (a trivial one) and
net/netfilter/nf_conntrack_proto_tcp.c (some pre-2.6.26 thing I
guess).

The first commits in my tree (after v2.6.26) are already in your tree,
you've got them by mail. It seems that git knows that.

Thanks.

 Documentation/DocBook/z8530book.tmpl |   38 ++-
 drivers/char/pcmcia/synclink_cs.c    |   32 +-
 drivers/char/synclink.c              |   37 ++-
 drivers/char/synclink_gt.c           |   33 +-
 drivers/char/synclinkmp.c            |   35 +-
 drivers/net/wan/Kconfig              |   13 +-
 drivers/net/wan/Makefile             |   11 +-
 drivers/net/wan/c101.c               |    6 +-
 drivers/net/wan/cosa.c               |  293 +++++++++-------
 drivers/net/wan/dscc4.c              |   23 +-
 drivers/net/wan/farsync.c            |   75 +++--
 drivers/net/wan/farsync.h            |    6 +
 drivers/net/wan/hd6457x.c            |   33 +-
 drivers/net/wan/hdlc.c               |   27 +-
 drivers/net/wan/hdlc_cisco.c         |   33 +-
 drivers/net/wan/hdlc_fr.c            |   73 +++--
 drivers/net/wan/hdlc_ppp.c           |   15 +-
 drivers/net/wan/hdlc_raw.c           |   15 +-
 drivers/net/wan/hdlc_raw_eth.c       |   19 +-
 drivers/net/wan/hdlc_x25.c           |   23 +-
 drivers/net/wan/hostess_sv11.c       |  382 ++++++++++++--------
 drivers/net/wan/lmc/lmc.h            |   11 +-
 drivers/net/wan/lmc/lmc_debug.c      |    7 +-
 drivers/net/wan/lmc/lmc_debug.h      |    6 +-
 drivers/net/wan/lmc/lmc_ioctl.h      |    2 +-
 drivers/net/wan/lmc/lmc_main.c       |  672 +++++++++++++++++++---------------
 drivers/net/wan/lmc/lmc_media.c      |   66 ++--
 drivers/net/wan/lmc/lmc_proto.c      |  146 ++++++--
 drivers/net/wan/lmc/lmc_proto.h      |   14 +-
 drivers/net/wan/lmc/lmc_var.h        |  360 ++++++++++++-------
 drivers/net/wan/pc300.h              |  228 +++++++-----
 drivers/net/wan/pc300_drv.c          |  217 +++++++-----
 drivers/net/wan/pc300_tty.c          |    6 +-
 drivers/net/wan/sealevel.c           |  361 +++++++++++-------
 drivers/net/wan/syncppp.c            |    9 +
 drivers/net/wan/wanxl.c              |   26 +-
 drivers/net/wan/z85230.c             |  193 ++++++----
 drivers/net/wan/z85230.h             |   10 +-
 include/linux/hdlc.h                 |    7 +
 include/net/syncppp.h                |    2 +
 net/wanrouter/wanmain.c              |   27 ++

-- 
Krzysztof Halasa
