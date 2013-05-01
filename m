From: Felix Fietkau <nbd@openwrt.org>
Subject: Regression in 3.9 caused by "bridge: respect RFC2863 operational
 state"
Date: Wed, 01 May 2013 21:02:29 +0200
Message-ID: <518166C5.4080904@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Sebastian Gottschall <s.gottschall@dd-wrt.com>
To: netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:43274 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755458Ab3EATCb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 May 2013 15:02:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

commit 576eb62598f10c8c7fd75703fe89010cdcfff596
Author: stephen hemminger <shemminger@vyatta.com>
Date:   Fri Dec 28 18:15:22 2012 +0000

bridge: respect RFC2863 operational state

This commit breaks putting a mac80211 4-address client mode interface in
a bridge and using it with WPA encryption.

wpa_supplicant has to receive EAP frames for authentication from the
bridge interface, since the rx handler hook steals them from the
wireless interface. However, it also keeps the interface operstate to
IF_OPER_DORMANT for as long as the WPA handshake is incomplete, which
causes the bridge code to drop EAP packets.

In the long run, I'd like to sort out this mess by passing EAP frames to
userspace via nl80211 - but since that will require userspace changes,
what do we do about this issue in the mean time?

- Felix
