From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v4 0/5] net: Unified offload configuration
Date: Thu,  3 Feb 2011 15:21:21 +0100 (CET)
Message-ID: <cover.1296741561.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:34559 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932201Ab1BCOVY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Feb 2011 09:21:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's a v4 of the ethtool unification patch series.

What's in it?
 1:
	the patch - implement unified ethtool setting ops
 2..3:
	implement interoperation between old and new ethtool ops
 4:
	include RX checksum in features and plug it into new framework
 5:
	convert loopback device to new framework

What is it good for?
 - unifies driver behaviour wrt hardware offloads
 - removes a lot of boilerplate code from drivers
 - allows better fine-grained control over used offloads

I'm testing this on ARM Gemini arch now. Patch to ethtool userspace too=
l
will follow this series. I'm not fond of the GFEATURES output I impleme=
nted -
please throw some suggestions on it if you can.

Driver conversions stay the same as in v2 - as for v3, I'll keep them
from resending until after the core code gets accepted.

Patches 2,4,5 are unchanged from v3.

Best Regards,
Micha=C5=82 Miros=C5=82aw


v1: http://marc.info/?l=3Dlinux-netdev&m=3D129245188832643&w=3D3

Changes from v3:
 - fixed kernel-doc and other comments
 - added HIGHDMA to never-changeable features
 - changed GFEATURES .size interpretation
 - changed feature strings
 - change __ethtool_set_flags() to reject invalid changes

Changes from v2:
 - rebase to net-next after merging v2 leading patches
 - fix missing comma in feature name table
 - force NETIF_F_SOFT_FEATURES in hw_features for simpler code
   (fixes a bug that disallowed changing GSO and GRO state)

Changes from v1:
 - split structures for GFEATURES/SFEATURES
 - naming of feature bits using GSTRINGS ETH_SS_FEATURES
 - strict checking of bits used in SFEATURES call
 - more comments and kernel-doc
 - rebased to net-next after 2.6.37


---

Micha=C5=82 Miros=C5=82aw (5):
  net: Introduce new feature setting ops
  net: ethtool: use ndo_fix_features for offload setting
  net: use ndo_fix_features for ethtool_ops->set_flags
  net: introduce NETIF_F_RXCSUM
  loopback: convert to hw_features

 drivers/net/loopback.c    |    9 +-
 include/linux/ethtool.h   |   86 ++++++++-
 include/linux/netdevice.h |   48 +++++-
 net/core/dev.c            |   49 ++++-
 net/core/ethtool.c        |  481 ++++++++++++++++++++++++++++---------=
--------
 5 files changed, 480 insertions(+), 193 deletions(-)

--=20
1.7.2.3

