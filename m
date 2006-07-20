From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] drivers/net/wireless/d80211: Check configuration type
 in hw->config_interface.
Date: Thu, 20 Jul 2006 10:54:42 +0200
Message-ID: <20060720105442.23fc9960@griffin.suse.cz>
References: <44BE958C.4030401@6wind.com>
	<200607191807.12360.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jean-Mickael Guerin <jean-mickael.guerin@6wind.com>,
	linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:26078 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S932572AbWGTIyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2006 04:54:43 -0400
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200607191807.12360.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Jul 2006 18:07:05 -0700, Michael Wu wrote:
> Why is that? Isn't there a BSSID in AP mode too? Perhaps it is calling 
> config_interface before setting the BSSID?

The bssid field in ieee80211_if_conf structure is not set in AP mode.
There is no need for that - you already have a MAC address of the AP
interface (from add_interface callback). That's your BSSID.

> adm8211 doesn't support AP mode yet, but it's good to know this crash won't 
> occur when it does. :)

The crash won't occur even without the patch - you will need to do
completely different things in adm8211_config_interface for AP mode than
for STA or IBSS mode and you will put some switch there anyway. No
reason for doing it now and bloating the code with a check for condition
that cannot happen.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
