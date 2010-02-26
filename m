From: Anatolij Gustschin <agust@denx.de>
Subject: [net-next-2.6 PATCH v3 0/3] Support for MPC512x FEC
Date: Fri, 26 Feb 2010 23:00:46 +0100
Message-ID: <1267221649-22754-1-git-send-email-agust@denx.de>
Cc: linuxppc-dev@ozlabs.org, "David S. Miller" <davem@davemloft.net>,
	Grant Likely <grant.likely@secretlab.ca>,
	Detlev Zundel <dzu@denx.de>, Wolfgang Denk <wd@denx.de>,
	John Rigby <jcrigby@gmail.com>,
	Anatolij Gustschin <agust@denx.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:54769 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966295Ab0BZWBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 17:01:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches attempt to provide support for the Freescale MPC512x
FEC in the fs_enet driver. The first cleanup patch replaces printk
by dev_xxx. The second and third attemt to support MPC5121 FEC
in the FEC driver.

Changes since previous version:

 - don't attempt to provide runtime selection of
   MPC5121 FEC support in the driver since it doesn't
   make sense. Select MPC5121 FEC support at compile time.
 - fix tx buffer alignment workaround patch to align
   only misaligned buffers.
 - address Eric's comments:
	ratelimit warning message and
	use 4-byte aligned skb->len for new properly
	aligned skb.

The patches are based on net-next-2.6 and has been
tested on the:
   - Freescale/STX "MPC5121ADS" board (board rev. 4) with
     a MPC5121e Rev. 2.
   - TQM860L and TQM855 boards.

Anatolij Gustschin (3):
  fs_enet: use dev_xxx instead of printk
  fs_enet: Add support for MPC512x to fs_enet driver
  fs_enet: add FEC TX buffer alignment workaround for MPC5121

 drivers/net/fs_enet/Kconfig        |   10 +++-
 drivers/net/fs_enet/fs_enet-main.c |   93 ++++++++++++++++++++++++++---------
 drivers/net/fs_enet/fs_enet.h      |   49 ++++++++++++++++++-
 drivers/net/fs_enet/mac-fcc.c      |    5 +-
 drivers/net/fs_enet/mac-fec.c      |   58 ++++++++++++++--------
 drivers/net/fs_enet/mac-scc.c      |    9 ++--
 drivers/net/fs_enet/mii-fec.c      |    4 +-
 7 files changed, 169 insertions(+), 59 deletions(-)

