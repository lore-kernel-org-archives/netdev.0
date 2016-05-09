From: Martin Willi <martin@strongswan.org>
Subject: [PATCH v2 0/2] wireless: Allow wiphy/hwsim management from user namespaces
Date: Mon,  9 May 2016 18:33:57 +0200
Message-ID: <1462811639-29906-1-git-send-email-martin@strongswan.org>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sitav-80046.hsr.ch ([152.96.80.46]:33191 "EHLO
	mail.strongswan.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300AbcEIQeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 12:34:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set enables user namespaces having CAP_NET_ADMIN to manage
wiphy devices and create/destroy hwsim radios.

The first patch allows a caller from a non-initial user namespace to run
privileged nl80211 phy/dev operations. The second patch enables hwsim
radio management over Netlink from such namespaces. Together, with these
patches an unprivileged test environment can create user/network
namespaces and set up abitrary simulated wireless networks.

Changes from v1:
  * Use a simple counter in hwsim to assign netgroups to net namespaces.
  * Store hwsim net_generic() data in a struct, add accessors.
  * On namespace exit, do not destroy hwsim radios originally created in
    the initial network namespace.

Martin Willi (2):
  nl80211: Allow privileged operations from user namespaces
  mac80211_hwsim: Allow managing radios from non-initial namespaces

 drivers/net/wireless/mac80211_hwsim.c |  97 +++++++++++++++++++++-
 net/wireless/nl80211.c                | 150 +++++++++++++++++-----------------
 2 files changed, 169 insertions(+), 78 deletions(-)
