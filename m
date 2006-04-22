From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [PATCH 8/10] d80211: get rid of default management interface
Date: Fri, 21 Apr 2006 19:44:31 -0700
Message-ID: <20060422024431.GJ27215@instant802.com>
References: <20060421225314.048983000.midnight@suse.cz> <20060421205328.39BE2482C1@silver.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeus1.kernel.org ([204.152.191.4]:62680 "EHLO zeus1.kernel.org")
	by vger.kernel.org with ESMTP id S1751201AbWDVVFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2006 17:05:31 -0400
Received: from DHOST002-70.dex002.intermedia.net (intermedia.net [64.78.20.36] (may be forged))
	by zeus1.kernel.org (8.13.1/8.13.1) with ESMTP id k3M2j0Oi012472
	for <netdev@vger.kernel.org>; Sat, 22 Apr 2006 02:45:00 GMT
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20060421205328.39BE2482C1@silver.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 21, 2006 at 10:53:28PM +0200, Jiri Benc wrote:
> Default management interface (wlanXap) confuses users. It is only needed for
> AP mode (and only until interfaces are converted to use native 802.11
> frames).

Or when using user space MLME in client mode which is something that I
just got working as far as scanning and association is concerned. In
other words, wpa_supplicant will be needing this interface..

> This patch removes default management interface. When a new interface is
> switched to AP mode, a management interface is created automatically. This
> also fixes some problems with multiple AP interfaces - now you have
> different management interface for each AP interface.

That sounds like something that could break multi-BSSID/SSID aware
hostapd. Are you saying that there would be new wlanXap like interface
for each BSS/VLAN interface? What are the problems this is fixing with
multiple AP interfaces? So far, hostapd has been responsible for
receiving all management from a single interface and then internally
decide which BSS/multi-SSID entry to use for each.

I would assume that hostapd could be changed to process frames from
multiple interfaces (at least if this is only for multi-BSSID, not for
multi-SSID/VLAN case). There may be some special cases, where it would
be easier to just be able to use one interface. Likewise, I would expect
single interface to be closer to a design that would be using netlink
for getting management frames into user space.

-- 
Jouni Malinen                                            PGP id EFC895FA
