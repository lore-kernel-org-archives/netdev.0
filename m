From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCHv3,GIT 0/5] support for DSA hardware ethernet switch chips
Date: Wed, 8 Oct 2008 01:43:42 +0200
Message-ID: <20081007234342.GA23200@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:40859 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754138AbYJGXnp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 19:43:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is version 3 of the DSA patch set, with various improvements
over v2:

- Move the dsa protocol state pointer in struct net_device to where
  the other protocol state pointers live (Ben Hutchings).

- Use bools for various functions returning bool, and define a couple
  of extern functions as extern in the header file (Stephen Hemminger).

- Get rid of dsa_tag_type (TAG_TYPE_{DSA,EDSA,TRAILER}) enum.  Since
  there is a ETH_P_* constant for each tagging type, just use those
  values to identify the tagging formats.

- Don't forget to use the _ppu versions of the MII access functions
  for the 88E6131, or PHY accesses won't work at all.

- Use u8 * consistently in the tag_*.c transmit routines (David Miller).

Note that this set depends on the phylib patches just posted.


The following changes since commit c65e0758d1a40bea4f956480fd52503c790911ba:
  Lennert Buytenhek (1):
        phylib: give mdio buses a device tree presence

are available in the git repository at:

  git://git.marvell.com/dsa.git master

Lennert Buytenhek (5):
      [NET] Distributed Switch Architecture protocol support
      [NET] dsa: add support for original DSA tagging format
      [NET] dsa: add support for the Marvell 88E6131 switch chip
      [NET] dsa: add support for Trailer tagging format
      [NET] dsa: add support for the Marvell 88E6060 switch chip

 include/linux/if_ether.h  |    3 +
 include/linux/netdevice.h |   24 ++
 include/net/dsa.h         |   37 ++++
 net/Kconfig               |    1 +
 net/Makefile              |    1 +
 net/dsa/Kconfig           |   59 +++++
 net/dsa/Makefile          |   13 ++
 net/dsa/dsa.c             |  392 ++++++++++++++++++++++++++++++++++
 net/dsa/dsa_priv.h        |  115 ++++++++++
 net/dsa/mv88e6060.c       |  287 +++++++++++++++++++++++++
 net/dsa/mv88e6123_61_65.c |  421 ++++++++++++++++++++++++++++++++++++
 net/dsa/mv88e6131.c       |  380 +++++++++++++++++++++++++++++++++
 net/dsa/mv88e6xxx.c       |  522 +++++++++++++++++++++++++++++++++++++++++++++
 net/dsa/mv88e6xxx.h       |   93 ++++++++
 net/dsa/slave.c           |  298 ++++++++++++++++++++++++++
 net/dsa/tag_dsa.c         |  194 +++++++++++++++++
 net/dsa/tag_edsa.c        |  213 ++++++++++++++++++
 net/dsa/tag_trailer.c     |  130 +++++++++++
 net/ethernet/eth.c        |   12 +

