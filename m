From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC/RFT 0/4] mac80211 QoS-related enhancements
Date: Wed, 30 Apr 2008 14:40:55 +0200
Message-ID: <20080430124055.091382000@sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ron Rindjunsky <ron.rindjunsky@intel.com>,
	Tomas Winkler <tomasw@gmail.com>,
	Ivo van Doorn <ivdoorn@gmail.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:52819 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756196AbYD3OHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2008 10:07:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Note: This patch series requires a number of other patches, notably Ivo's
rt2x00 update and Ivo's mac80211 patch
	"mac80211: Replace ieee80211_tx_control->key_idx with ieee80211_key_conf"

Any testing of this series is welcome, even just the first patch by itself
(especially with drivers other than b43), it doesn't make sense to test with
patch 2 and not 3 though, so if you're going to test one by one treat 2/3 as
a set.

This series of patches reworks mac80211 step-by-step to use more generic
code instead of having implementations of everything built-in.

The first patch (mac80211: use rate index in TX control) is just preparation
(but I'm not entirely sure about the iwlwifi changes, haven't tested them yet.)

The second patch I want input from netdev from, what do people think about
using the GSO code that way? It does seem like a bit of an abuse to fill the
skb->next pointer from within ->hard_start_xmit() but it works and allows
me to get rid of all the weird retry logic in mac80211 (patch three). Finally,
the fourth patch converts mac80211 and drivers to be multiqueue aware.

There are still a number of things missing in this series:
 * we need to rework the classification function to be a real classifier
   that we install on our wme qdisc
 * we should allow tuning the medium access parameters via the wme qdisc

johannes

