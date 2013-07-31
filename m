From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: 3.10, iwlwifi 6200AGN: AP changed bandwidth in a way we can't
 support - disconnect
Date: Wed, 31 Jul 2013 10:59:56 +0200
Message-ID: <20130731085956.GC1681@redhat.com>
References: <20130729163452.GA454@hexapodia.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes.berg@intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
To: Andy Isaacson <adi@hexapodia.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43179 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759185Ab3GaI4v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 04:56:51 -0400
Content-Disposition: inline
In-Reply-To: <20130729163452.GA454@hexapodia.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 29, 2013 at 09:34:52AM -0700, Andy Isaacson wrote:
> After upgrading to 3.10.4 and traveling to Europe I'm often suffering
> from failures to associate with the following in dmesg:
> 
> [   37.351621] wlan0: authenticate with 64:70:02:e6:a6:ba
> [   37.364701] wlan0: send auth to 64:70:02:e6:a6:ba (try 1/3)
> [   37.366358] wlan0: authenticated
> [   37.368543] wlan0: associate with 64:70:02:e6:a6:ba (try 1/3)
> [   37.372765] wlan0: RX AssocResp from 64:70:02:e6:a6:ba (capab=0x431 status=0 aid=8)
> [   37.380190] wlan0: associated
> [   37.438935] wlan0: AP 64:70:02:e6:a6:ba changed bandwidth, new config is 2447 MHz, width 1 (2447/0 MHz)
> [   37.438941] wlan0: AP 64:70:02:e6:a6:ba changed bandwidth in a way we can't support - disconnect
> 
> I hacked the driver to do
> 
> -                  "AP %pM changed bandwidth, new config is %d MHz, width %d (%d/%d MHz)\n",
> +                  "AP %pM changed bandwidth, new config is %d MHz, width %d (%d/%d MHz) flags %x/%x\n",
>                    ifmgd->bssid, chandef.chan->center_freq, chandef.width,
> -                  chandef.center_freq1, chandef.center_freq2);
> +                  chandef.center_freq1, chandef.center_freq2, flags, ifmgd->flags);
> 
> and
> 
> -       if (flags != (ifmgd->flags & (IEEE80211_STA_DISABLE_HT |
> +       if ((flags != 0x810 && ifmgd->flags != 0x804) && (
> +            flags != (ifmgd->flags & (IEEE80211_STA_DISABLE_HT |
> 
> and the result is a working link with

We have few reports about this. Johannes, proposed this patch
http://p.sipsolutions.net/9d1dd0734d2c3a7a.txt

Could you check if it fixes the problem for you?

Stanislaw
