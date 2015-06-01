From: sfeldma@gmail.com
Subject: [PATCH net-next 0/5] rocker: enable by default untagged VLAN support
Date: Mon,  1 Jun 2015 11:39:01 -0700
Message-ID: <1433183947-13095-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:36305 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751546AbbFAShZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 14:37:25 -0400
Received: by pdjm12 with SMTP id m12so30901480pdj.3
        for <netdev@vger.kernel.org>; Mon, 01 Jun 2015 11:37:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

This patch set is a followup to Simon Horman's RFC patch:

   [PATCH/RFC net-next] rocker: by default accept untagged packets

Now, on port probe, we install untagged VLAN (vid=0) support for each port
as the default.  This is equivalent to the command:

   bridge vlan add vid 0 dev DEV self

Accepting untagged VLAN pkts is a reasonable default, but the user could
override this with:

   bridge vlan del vid 0 dev DEV self

With this, we no longer need 8021q module to install vid=0 when port interface
opens.  In fact, we don't need support for legacy VLAN ndo ops at all since
they're superseded by bridge_setlink/dellink.  So remove legacy VLAN ndo ops
support in driver.  (The legacy VLAN ndo ops are supported by bonding/team
drivers, but don't fit into the transaction model offered by switchdev, so
switching all VLAN functions to bridge_setlink/dellink switchdev support gets
us stacked driver + transaction model support).

Scott Feldman (5):
  rocker: zero allocate ports array
  rocker: cleanup vlan table on error adding vlan
  rocker: install untagged VLAN (vid=0) support for each port
  rocker: install/remove router MAC for untagged VLAN when
    joining/leaving bridge
  rocker: remove support for legacy VLAN ndo ops

 drivers/net/ethernet/rocker/rocker.c |  105 ++++++++++++++++------------------
 1 file changed, 50 insertions(+), 55 deletions(-)

-- 
1.7.10.4
