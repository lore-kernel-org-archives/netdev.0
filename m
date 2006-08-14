From: Johannes Berg <johannes@sipsolutions.net>
Subject: wlan#ap seems bogus
Date: Mon, 14 Aug 2006 10:22:34 +0200
Message-ID: <44E032CA.4040107@sipsolutions.net>
References: <44E02F41.2060300@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:28108 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750861AbWHNIWh
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 04:22:37 -0400
To: Jouni Malinen <jkm@devicescape.com>, Jiri Benc <jbenc@suse.cz>
In-Reply-To: <44E02F41.2060300@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As far as I understand the entire point of the wlan#ap interface is to
receive all management relevant management frames. (If that's wrong, reply
now and don't read the rest)

Hence, I think it ought to be named 'wlan#mgmt' instead. However, I think
it's hard-coded existence is bogus.

How about we just add a new interface mode called MGT_MONITOR and
wpa_supplicant simply creates a new device via the regular sysfs mechanism,
and then sets that MGT_MONITOR mode via the relevant WEXT ioctl? iwconfig
doesn't even need to be taught about this mode except for display
purposes...

Also, like I mentioned previously, the device naming can be changed by the
user and there's no guarantee that wlan0ap corresponds to wmaster0. Etc. But
if wpa_supplicant simply created the device itself, it could give it any
name, say wlan0_mgt (if it was controlling wlan0), but if that name is
already taken it simply appends a number or something until it hits a device
name that's still free (or gives up after 100 tries or so...) :)

johannes

PS: In case you're wondering, this is the last mail in my series. Phew!
