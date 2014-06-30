From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next v2 0/4] be2net: patch set
Date: Mon, 30 Jun 2014 13:01:29 +0530
Message-ID: <1404113493-14851-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:13552 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752251AbaF3H3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 03:29:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2 change: merged 2 lines into one in patch 4

Patch 1 refactors be_cmd_get_profile_config() routine to reduce
code duplication by using the be_cmd_notify_wait() routine, instead
of using a separate variant of the code for MBOX and MCCQ.

Patch 2 introduces the required FW-cmd code in the PF to query
RSS support on a VF. This is in preparation for patch 3.

Patch 3 adds support for the PF driver to re-configure the resource
distribution in FW based on the number of VFs enabled by the user. When
the user is not interested in enabling VFs, all resources of a port are
set-aside for the PF. If less than maximum number of VFs are enabled, then
each VF gets a better share of the resources and can now enable RSS (if
the interface supports it.)

Patch 4 is a minor fix to re-enable HW vlan filtering as soon as the number
of vlans programmed is within the HW limit.

Please consider applying to net-next tree. Thanks!

Kalesh AP (1):
  be2net: re-enable vlan filtering mode asap

Vasundhara Volam (3):
  be2net: remove be_cmd_get_profile_config_mbox/mccq() variants
  be2net: read VF's capabilities from GET_PROFILE_CONFIG cmd
  be2net: create optimal number of queues on SR-IOV config

 drivers/net/ethernet/emulex/benet/be.h      |    9 +-
 drivers/net/ethernet/emulex/benet/be_cmds.c |  226 ++++++++++++++++-----------
 drivers/net/ethernet/emulex/benet/be_cmds.h |    9 +-
 drivers/net/ethernet/emulex/benet/be_main.c |  141 ++++++++++-------
 4 files changed, 230 insertions(+), 155 deletions(-)
