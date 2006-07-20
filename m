From: "Ivo Van Doorn" <ivdoorn@gmail.com>
Subject: Re: [PATCH] drivers/net/wireless/d80211: Check configuration type in hw->config_interface.
Date: Thu, 20 Jul 2006 18:19:52 +0200
Message-ID: <a32f33a40607200919t38a2d123y3626a74fa87ac725@mail.gmail.com>
References: <44BE958C.4030401@6wind.com>
	 <20060720104634.0a8961da@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jean-Mickael Guerin" <jean-mickael.guerin@6wind.com>,
	linville@tuxdriver.com, netdev@vger.kernel.org,
	"Michael Wu" <flamingice@sourmilk.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.179]:54211 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1030340AbWGTQTy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jul 2006 12:19:54 -0400
Received: by py-out-1112.google.com with SMTP id c39so778486pyd
        for <netdev@vger.kernel.org>; Thu, 20 Jul 2006 09:19:53 -0700 (PDT)
To: "Jiri Benc" <jbenc@suse.cz>
In-Reply-To: <20060720104634.0a8961da@griffin.suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> > This patch prevents a NULL pointer dereferencing in AP mode:
> > ieee80211_if_config will set conf->bssid only if device is of type STA
> > or IBSS.
> > I see it using following commands right after module loading (with rt61)
> > # iwconfig wlan0 mode Master
> > # ifconfig wlan0 up
>
> The patch seems to fix the problem at a wrong place. rt2x00 has broken
> add_interface handler - it allows adding of AP interface even though the
> driver doesn't support AP mode. It is add_interface callback that should
> be fixed in rt2x00.

Well rt2x00 does support AP mode, our latest CVS tree (patches for
wireless-dev are in progress) has even shown a working configuration
for some users.
So add_interface is correct at allowing the AP interface, perhaps some
more steps
are required to make it completely work, but it is work in progress.

> The check in the patch most likely won't be needed even after AP mode
> support is added to rt2x00 - the driver needs to handle AP mode
> differently so config_interface callback will be rewritten anyway.

I'll make a check to see if the bssid is NULL or invalid in the
config_bssid() function,
and make sure that in AP mode the MAC is written as BSSID.

Ivo
