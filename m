From: Johannes Berg <johannes@sipsolutions.net>
Subject: RE: [RFC 2/3] make d80211 use cfg80211
Date: Fri, 15 Sep 2006 08:41:46 +0200
Message-ID: <1158302506.2921.6.camel@ux156>
References: <C86180A8C204554D8A3323D8F6B0A29F01785205@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, Jean Tourrilhes <jt@hpl.hp.com>,
	Jiri Benc <jbenc@suse.cz>,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
	Mohamed Abbas <mabbas@linux.intel.com>,
	Ulrich Kunitz <kune@deine-taler.de>,
	Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:31151 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750829AbWIOGlJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Sep 2006 02:41:09 -0400
To: Simon Barber <simon@devicescape.com>
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F01785205@dhost002-46.dex002.intermedia.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simon,

> Does the packet injection allow hostapd to use nl80211 instead of the
> wlan0ap interface to send management frames? 

It's intended that it does that, yes.

> Important features for this
> include requesting a transmit status - i.e. the ability for
> hostapd/wpa_supplicant to know if the frame got acked or not.

Yeah, I'm aware of that. I think it can actually request the transmit
status now using the flags (would have to check), but the transmit
status won't get sent over netlink but still over the wlan0ap interface.
I haven't modified that part yet, but it shouldn't be hard to do.

I'll have to look at that closer some time (soon). I think if you
request the transmit status I'll have to save the netlink_pid of the
request and then unicast back the transmit status. That shouldn't be
hard to do at all (obviously requires that hostapd keeps the netlink
socket open but it should do that anyway)

johannes
