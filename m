From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH v4 0/5] alx: add statistics
Date: Thu,  9 Jan 2014 10:09:26 +0100
Message-ID: <1389258571-10083-1-git-send-email-sd@queasysnail.net>
Cc: bhutchings@solarflare.com, johannes@sipsolutions.net,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	Sabrina Dubroca <sd@queasysnail.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpfb1-g21.free.fr ([212.27.42.9]:34130 "EHLO
	smtpfb1-g21.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754746AbaAIJKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 04:10:39 -0500
Received: from smtp5-g21.free.fr (smtp5-g21.free.fr [212.27.42.5])
	by smtpfb1-g21.free.fr (Postfix) with ESMTP id E962077CBCB
	for <netdev@vger.kernel.org>; Thu,  9 Jan 2014 10:10:31 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the alx driver doesn't support statistics [1,2]. The
original alx driver [3] that Johannes Berg modified provided
statistics. This patch is an adaptation of the statistics code from
the original driver to the alx driver included in the kernel.

v4:
 - modified the assignements of hw stats to netstats (Ben Hutchings)
 - added comments to describe the stats fields (copied from atlx)

v3:
 - renamed __alx_update_hw_stats to alx_update_hw_stats (Stephen Hemminger)

v2:
 - use u64 instead of unsigned long  (Ben Hutchings)
 - implement ndo_get_stats64 instead of ndo_get_stats (Ben Hutchings)
 - use EINVAL instead of ENOTSUPP  (Ben Hutchings)
 - add BUILD_BUG_ON to check the size of the stats (Johannes Berg, Ben
   Hutchings)
 - add a comment regarding persistence of the stats (Stephen Hemminger)
 - align assignments in __alx_update_hw_stats


[1] https://bugzilla.kernel.org/show_bug.cgi?id=63401
[2] http://www.spinics.net/lists/netdev/msg245544.html
[3] https://github.com/mcgrof/alx


Sabrina Dubroca (5):
  alx: add a hardware stats structure
  alx: add constants for the stats fields
  alx: add stats update function
  alx: add alx_get_stats64 operation
  alx: add stats to ethtool

 drivers/net/ethernet/atheros/alx/alx.h     |   3 +
 drivers/net/ethernet/atheros/alx/ethtool.c | 101 +++++++++++++++++++++++++++++
 drivers/net/ethernet/atheros/alx/hw.c      |  58 +++++++++++++++++
 drivers/net/ethernet/atheros/alx/hw.h      |  71 ++++++++++++++++++++
 drivers/net/ethernet/atheros/alx/main.c    |  50 ++++++++++++++
 drivers/net/ethernet/atheros/alx/reg.h     |  52 +++++++++++++--
 6 files changed, 331 insertions(+), 4 deletions(-)

-- 
1.8.5.2
