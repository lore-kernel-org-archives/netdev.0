From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: wlan#ap seems bogus
Date: Mon, 14 Aug 2006 08:58:47 -0700
Message-ID: <20060814155847.GC1196@instant802.com>
References: <44E02F41.2060300@sipsolutions.net> <44E032CA.4040107@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-5.dex002.intermedia.net ([64.78.21.20]:5572 "EHLO
	dhost002-5.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751185AbWHNP6x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 11:58:53 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <44E032CA.4040107@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 14, 2006 at 10:22:34AM +0200, Johannes Berg wrote:
> As far as I understand the entire point of the wlan#ap interface is to
> receive all management relevant management frames. (If that's wrong, reply
> now and don't read the rest)
> 
> Hence, I think it ought to be named 'wlan#mgmt' instead. However, I think
> it's hard-coded existence is bogus.
> 
> How about we just add a new interface mode called MGT_MONITOR and
> wpa_supplicant simply creates a new device via the regular sysfs mechanism,
> and then sets that MGT_MONITOR mode via the relevant WEXT ioctl? iwconfig
> doesn't even need to be taught about this mode except for display
> purposes...

Isn't this already done? I don't remember what happened with client mode
case, but at least hostapd is requesting the management interface
dynamically at startup time.

> Also, like I mentioned previously, the device naming can be changed by the
> user and there's no guarantee that wlan0ap corresponds to wmaster0. Etc. But
> if wpa_supplicant simply created the device itself, it could give it any
> name, say wlan0_mgt (if it was controlling wlan0), but if that name is
> already taken it simply appends a number or something until it hits a device
> name that's still free (or gives up after 100 tries or so...) :)

Same here.. hostapd gets the ifindex from kernel and doesn't care about
the name.

-- 
Jouni Malinen                                            PGP id EFC895FA
