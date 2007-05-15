From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: mac80211 ad-hoc: carrier not set up [was: Panic in ieee_80211_ibss_add_sta]
Date: Tue, 15 May 2007 23:59:28 +0200
Message-ID: <200705152359.29200.IvDoorn@gmail.com>
References: <20070515152842.GA26481@charon.n2.diac24.net> <20070515171202.GD15105@tuxdriver.com> <20070515193309.GA29184@charon.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: David Lamparter <lists@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.235]:65006 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758478AbXEOWBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2007 18:01:11 -0400
Received: by wx-out-0506.google.com with SMTP id h31so2087942wxd
        for <netdev@vger.kernel.org>; Tue, 15 May 2007 15:01:09 -0700 (PDT)
In-Reply-To: <20070515193309.GA29184@charon.n2.diac24.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> However, ad-hoc still does not work, since the network device's
> carrier status does not seem to be properly set. (It remains
> in NO-CARRIER even after "wlan0: Selected IBSS BSSID
> 92:68:a2:db:de:45 based on configured SSID". I dirtily hacked
> around that with the following two-liner:

I was aware of the recent rt2x00 adhoc breakage but hadn't looked into it yet,
the below suggestion about the netif_carrier does make sense though,
since the last report it was working was before rt2x00 removed the ieee80211_netif
calls, and the first report of its breakage was some time after the removal.
(Since a lot of code has been moved around in between the ieee80211_netif wasn't
the first thing that I would have thought of as a probable cause. ;) )

> --- wireless-dev/net/mac80211/ieee80211_sta.c.orig	2007-05-15 20:19:55.000000000 +0200
> +++ wireless-dev/net/mac80211/ieee80211_sta.c	2007-05-15 21:19:38.362587215 +0200
> @@ -2448,6 +2448,7 @@
>  	mod_timer(&ifsta->timer, jiffies + IEEE80211_IBSS_MERGE_INTERVAL);
>  
>  	ieee80211_rx_bss_put(dev, bss);
> +	netif_carrier_on(dev);
>  
>  	return res;
>  }
> @@ -2648,6 +2649,7 @@
>  
>  	ifsta->ssid_set = len ? 1 : 0;
>  	if (sdata->type == IEEE80211_IF_TYPE_IBSS && !ifsta->bssid_set) {
> +		netif_carrier_off(dev);
>  		ifsta->ibss_join_req = jiffies;
>  		ifsta->state = IEEE80211_IBSS_SEARCH;
>  		return ieee80211_sta_find_ibss(dev, ifsta);
> 
> 
> However, I have NO CLUE WHAT I'M DOING THERE! Make a proper fix!
> (Especially, I think it needs more netif_carrier_off calls in
> different places.)
> 
> 
> Anyway, thanks for my now-working wireless,

Ivo
