From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v3 0/5] net: Unified offload configuration
Date: Sat, 29 Jan 2011 19:39:08 +0100 (CET)
Message-ID: <cover.1296325509.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:60409 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754838Ab1A2SjM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Jan 2011 13:39:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's a next version of the ethtool unification patch series.

What's in it?
 1:
	the patch - implement unified ethtool setting ops
 2..3:
	implement interoperation between old and new ethtool ops
 4:
	include RX checksum in features and plug it into new framework
 5:
	convert loopback pseudodevice to new framework

What is it good for?
 - unifies driver behaviour wrt hardware offloads
 - removes a lot of boilerplate code from drivers
 - allows better fine-grained control over used offloads

I'm testing this on ARM Gemini arch now. Patch to ethtool userspace too=
l
will follow this series. I'm not fond of the GFEATURES output I impleme=
nted -
please throw some suggestions on it if you can.

Driver conversions stay the same as in v2 - I'll resend them Cc'ing the=
ir
maintainters after the core interfaces get accepted.

Best Regards,
Micha=C5=82 Miros=C5=82aw

---

v1: http://marc.info/?l=3Dlinux-netdev&m=3D129245188832643&w=3D3

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
 include/linux/ethtool.h   |   87 ++++++++-
 include/linux/netdevice.h |   47 +++++-
 net/core/dev.c            |   47 ++++-
 net/core/ethtool.c        |  472 ++++++++++++++++++++++++++++---------=
--------
 5 files changed, 469 insertions(+), 193 deletions(-)

--=20
1.7.2.3

