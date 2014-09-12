From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 0/8] be2net: patch set
Date: Fri, 12 Sep 2014 17:39:13 +0530
Message-ID: <1410523761-1744-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:21722 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753743AbaILMGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 08:06:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch 1 fixes some minor issues with log messages in be2net.

Patch 2 replaces strcpy() calls with strlcpy() to avoid possible buffer
overflow.

Patch 3 improves the RX buffer posting scheme for jumbo frames.

Patch 4 replaces the use of v0 of SET_FLOW_CONTROL cmd with v1 to receive
a definitive completion status from FW.

Patch 5 adds support for ethtool "-m" ethtool option.

Patch 6 fixes port-type reporting via ethtool get_settings for QSFP/SFP+
interfaces.

Patch 7 fixes the usage of MODIFY_EQD FW cmd to target a max of 8 EQs on
Lancer chip. 

Patch 8 enables PCIe error reporting even for VFs.

Pls consider applying this patch set to net-next. Thanks.

Kalesh AP (3):
  be2net: fix RX fragment posting for jumbo frames
  be2net: send a max of 8 EQs to be_cmd_modify_eqd() on Lancer
  be2net: enable PCIe error reporting on VFs too

Mark Leonard (1):
  be2net: add ethtool "-m" option support

Ravikumar Nelavelli (1):
  be2net: fix port-type reporting in get_settings

Suresh Reddy (1):
  be2net: use v1 of SET_FLOW_CONTROL command

Vasundhara Volam (2):
  be2net: fix some log messages
  be2net: replace strcpy with strlcpy

 drivers/net/ethernet/emulex/benet/be.h         |    2 +-
 drivers/net/ethernet/emulex/benet/be_cmds.c    |  112 ++++++++++++++++++++++--
 drivers/net/ethernet/emulex/benet/be_cmds.h    |   41 +++++----
 drivers/net/ethernet/emulex/benet/be_ethtool.c |  105 +++++++++++++++++++----
 drivers/net/ethernet/emulex/benet/be_main.c    |   47 ++++++-----
 5 files changed, 242 insertions(+), 65 deletions(-)
