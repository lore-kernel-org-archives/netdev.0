From: Holger Schurig <holgerschurig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] wireless: wext: allocate space for NULL-termination for 32byte SSIDs
Date: Tue, 15 Dec 2009 11:30:58 +0100
Message-ID: <200912151130.59103.holgerschurig@gmail.com>
References: <1260650850-16163-1-git-send-email-daniel@caiaq.de> <1260871411.3692.4.camel@johannes.local> <1260871634.3692.6.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, daniel-rDUAYElUppE@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	m.hirsch-5g8ninUHluJWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1260871634.3692.6.camel-YfaajirXv2244ywRPIzf9A@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> drivers/net/wireless/libertas$ grep lbs_deb_ * | grep ssid
> |grep '%s' 
> assoc.c:	lbs_deb_join("current SSID '%s', ssid length %u\n",
> assoc.c:	lbs_deb_join("requested ssid '%s', ssid length %u\n",
> assoc.c:	lbs_deb_join("ADHOC_START: SSID '%s', ssid
>               length %u\n", 
> scan.c:		lbs_deb_wext("set_scan, essid '%s'\n",

All those lines are gone once my cfg80211 lands.

Do you know any way to make sparse moan about them?


BTW: the libertas firmware sometimes treat an SSID as a 
zero-terminated string. There are some firmware commands that 
accept just an u8[32] bytes for the SSID, but not an ssid_len, 
e.g. in the CMD_802_11_AD_HOC_START command.

You therefore can't connect to the otherwise legitimate SSID of 
TEST\0\0\0.

-- 
http://www.holgerschurig.de
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
