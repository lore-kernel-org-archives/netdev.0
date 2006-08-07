From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: 802.11/crypto questions
Date: Mon, 7 Aug 2006 10:29:46 -0700
Message-ID: <20060807172946.GI4702@instant802.com>
References: <1154410852.17333.4.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-83.dex002.intermedia.net ([64.78.20.216]:32378 "EHLO
	dhost002-83.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S932143AbWHGR3y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 13:29:54 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1154410852.17333.4.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 01, 2006 at 07:40:52AM +0200, Johannes Berg wrote:

> Since there's been lots of talk about multi-STA or multi-BSSID devices
> (more than one client, more than one AP on the same PHY) and I was just
> looking into some crypto stuff on bcm43xx, it got me wondering.
> 
> The bcm43xx has an elaborate group key matching thingie which will be
> useful if it's all WPA2, but if it's say just plain WEP, then that is a
> problem since you'd either need to use the same keys or disable the
> bcm43xx crypto hardware.
> 
> Hence, I suppose the question really is -- does the dscape stack allow
> changing the 'sw crypto needed' flag on the fly?

Depends on what exactly you mean with "on the fly". We have indeed
changed between doing software and hardware crypto for some cases, e.g.,
when enabling another BSS while one BSS is using static WEP (which would
need default WEP keys in hwaccel) in one BSS, we may disable hwaccel for
the receive case. Not all configuration changes are yet supported with
minimal modification, i.e., hostapd may end up having to disconnect all
stations and start over with such a change, but still, the driver should
be prepared on dynamically changing the key configuration and this can
include moving some keys from hwaccel to software.

If it can be done without major effort, I would recommend making the
low-level drivers quite flexible as far as configuring keys to hardware
accelaration is concerned. Depending on the hardware design, there may
be multiple different ways of doing this and some multi-BSS
configurations are likely to require changes in how the keys are used
between hardware and software.

-- 
Jouni Malinen                                            PGP id EFC895FA
