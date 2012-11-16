From: Antonio Quartulli <ordex@autistici.org>
Subject: pull request: batman-adv 2012-11-16
Date: Fri, 16 Nov 2012 09:49:14 +0100
Message-ID: <1353055758-2901-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org,
	Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:34795 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833Ab2KPIuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 03:50:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

here is small set of fixes intended for net/linux-3.7.
These patches are fixing some interoperability problems due to the features we
added in 3.7. Mainly we have two big issues: one is preventing clients connected
to the mesh network to contact any other hosts, caused by a not proper
translation table handling; the second one compromises the AP isolation feature
causing it to be completely useless, no matter it was on or off.

Please, let me know if there is any problem.

Thank you very much!
		Antonio



The following changes since commit 80d11788fb8f4d9fcfae5ad508c7f1b65e8b28a3:

  Revert "drivers/net/phy/mdio-bitbang.c: Call mdiobus_unregister before mdiobus_free" (2012-11-14 22:32:15 -0500)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-fix-for-davem

for you to fetch changes up to 74490f969155caf1ec945ad2d35d3a8eec6be71d:

  batman-adv: process broadcast packets in BLA earlier (2012-11-16 09:36:54 +0100)

----------------------------------------------------------------
Included fixes are:
- update the client entry status flags when using the "early client
  detection". This makes the Distributed AP isolation correctly work;
- transfer the client entry status flags when recovering the translation
  table from another node. This makes the Distributed AP isolation correctly
  work;
- prevent the "early client detection mechanism" to add clients belonging to
  other backbone nodes in the same LAN. This breaks connectivity when using this
  mechanism together with the Bridge Loop Avoidance
- process broadcast packets with the Bridge Loop Avoidance before any other
  component. BLA can possibly drop the packets based on the source address. This
  makes the "early client detection mechanism" correctly work when used with
  BLA.

----------------------------------------------------------------
Antonio Quartulli (4):
      batman-adv: fix tt_global_entries flags update
      batman-adv: correctly pass the client flag on tt_response
      batman-adv: don't add TEMP clients belonging to other backbone nodes
      batman-adv: process broadcast packets in BLA earlier

 net/batman-adv/soft-interface.c    | 12 ++++++------
 net/batman-adv/translation-table.c | 15 ++++++++++++++-
 2 files changed, 20 insertions(+), 7 deletions(-)
