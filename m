From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] drivers/net/wireless/d80211: Check configuration type
 in hw->config_interface.
Date: Thu, 20 Jul 2006 10:46:34 +0200
Message-ID: <20060720104634.0a8961da@griffin.suse.cz>
References: <44BE958C.4030401@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	"Ivo Van Doorn" <ivdoorn@gmail.com>,
	Michael Wu <flamingice@sourmilk.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:60893 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S932547AbWGTIqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2006 04:46:36 -0400
To: Jean-Mickael Guerin <jean-mickael.guerin@6wind.com>
In-Reply-To: <44BE958C.4030401@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Jul 2006 22:26:52 +0200, Jean-Mickael Guerin wrote:
> This patch prevents a NULL pointer dereferencing in AP mode:
> ieee80211_if_config will set conf->bssid only if device is of type STA 
> or IBSS.
> I see it using following commands right after module loading (with rt61)
> # iwconfig wlan0 mode Master
> # ifconfig wlan0 up

The patch seems to fix the problem at a wrong place. rt2x00 has broken
add_interface handler - it allows adding of AP interface even though the
driver doesn't support AP mode. It is add_interface callback that should
be fixed in rt2x00.

The check in the patch most likely won't be needed even after AP mode
support is added to rt2x00 - the driver needs to handle AP mode
differently so config_interface callback will be rewritten anyway.

adm8211 driver doesn't have this problem and doesn't need to be
modified.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
