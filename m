From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v5 RESEND 0/9] net: Unified offload configuration
Date: Sun, 13 Feb 2011 12:11:43 +0100 (CET)
Message-ID: <cover.1297594674.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:50506 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754088Ab1BMLLr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Feb 2011 06:11:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's a v5 of the ethtool unification patch series.

What's in it?
 1..4:
	cleanups for the core patches
 5:
	the patch - implement unified ethtool setting ops
 6..7:
	implement interoperation between old and new ethtool ops
 8:
	include RX checksum in features and plug it into new framework
 9:
	convert loopback device to new framework

What is it good for?
 - unifies driver behaviour wrt hardware offloads
 - removes a lot of boilerplate code from drivers
 - allows better fine-grained control over used offloads

This version is not tested in any way, yet. I hope I've split all clean=
ups
from the core patches now.

Best Regards,
Micha=C5=82 Miros=C5=82aw

[This is a resend because of broken headers in previous submission. Sor=
ry
for the delay - I got disconnected from my dev machine for a while.]

v1: http://marc.info/?l=3Dlinux-netdev&m=3D129245188832643&w=3D3

Changes from v4:
 - more split cleanups
 - fix error return for ETHTOOL_SFLAGS
 - fix ETHTOOL_G* compatibility for not converted drivers

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


Micha=C5=82 Miros=C5=82aw (9):
  ethtool: move EXPORT_SYMBOL(ethtool_op_set_tx_csum) to correct place
  ethtool: enable GSO and GRO by default
  ethtool: factorize ethtool_get_strings() and ethtool_get_sset_count()
  ethtool: factorize get/set_one_feature
  net: Introduce new feature setting ops
  net: ethtool: use ndo_fix_features for offload setting
  net: use ndo_fix_features for ethtool_ops->set_flags
  net: introduce NETIF_F_RXCSUM
  loopback: convert to hw_features

 drivers/net/loopback.c    |    9 +-
 include/linux/ethtool.h   |   86 ++++++++-
 include/linux/netdevice.h |   48 ++++-
 net/core/dev.c            |   49 ++++-
 net/core/ethtool.c        |  527 +++++++++++++++++++++++++++++--------=
-------
 5 files changed, 526 insertions(+), 193 deletions(-)

--=20
1.7.2.3

