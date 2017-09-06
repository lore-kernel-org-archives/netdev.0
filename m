From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: hung task in mac80211
Date: Wed, 06 Sep 2017 14:48:35 +0200
Message-ID: <1504702115.13457.16.camel@sipsolutions.net>
References: <CAGnkfhwi9MmtLneeU23iWEGLj9cb1ODb3KzzOqTDvA6nNVsugg@mail.gmail.com>
         <20170906144019.1c98a636@elisabeth> (sfid-20170906_144115_600908_441D9559)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Stefano Brivio <sbrivio@redhat.com>,
        Matteo Croce <mcroce@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170906144019.1c98a636@elisabeth> (sfid-20170906_144115_600908_441D9559)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'll look in a bit - but

> +			mutex_unlock(&sta->ampdu_mlme.mtx);
>  			___ieee80211_stop_rx_ba_session(
>  				sta, tid, WLAN_BACK_RECIPIENT,
>  				WLAN_REASON_QSTA_TIMEOUT, true);

This already has three underscores so shouldn't drop.

> 
> +			mutex_unlock(&sta->ampdu_mlme.mtx);
>  			___ieee80211_stop_rx_ba_session(

ditto

> +			mutex_unlock(&sta->ampdu_mlme.mtx);
>  			__ieee80211_start_rx_ba_session(sta, 0, 0,
> 0, 1, tid,

maybe this one needs a ___ version then?

> +			mutex_unlock(&sta->ampdu_mlme.mtx);
>  			___ieee80211_stop_rx_ba_session(
> 
already ___

I'm surprised nobody saw this before - though perhaps Sebastian's
useless report is the same.

johannes
