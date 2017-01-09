From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: SIOCSIWFREQ while in NL80211_IFTYPE_STATION
Date: Mon, 09 Jan 2017 12:05:10 +0100
Message-ID: <1483959910.17582.25.camel@sipsolutions.net>
References: <685811c3-6247-77fd-8c70-617951886451@linaro.org>
         <1483616301.4394.6.camel@sipsolutions.net>
         <92e60cb2-8bb4-df03-3434-4a055f575df0@linaro.org>
         <1483625204.4394.23.camel@sipsolutions.net>
         <f8e8b557-3e7b-cc1a-c31a-91f9d754e683@linaro.org>
         (sfid-20170105_153832_371808_8A30C9BF)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jorge Ramirez <jorge.ramirez-ortiz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Daniel Lezcano <daniel.lezcano-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <f8e8b557-3e7b-cc1a-c31a-91f9d754e683-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org> (sfid-20170105_153832_371808_8A30C9BF)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-01-05 at 15:38 +0100, Jorge Ramirez wrote:

> do you mean this?
> 
> [jramirez@igloo ~ (debian-qcom-dragonboard410c-16.09-local $)]$ git
> diff
> diff --git a/net/wireless/wext-sme.c b/net/wireless/wext-sme.c
> index a4e8af3..c56bac5 100644
> --- a/net/wireless/wext-sme.c
> +++ b/net/wireless/wext-sme.c
> @@ -106,30 +106,7 @@ int cfg80211_mgd_wext_siwfreq(struct net_device
> *dev,
>                          goto out;
>          }
> 
> -
>          wdev->wext.connect.channel = chan;
> -
> -   /*
> -    * SSID is not set, we just want to switch monitor channel,
> -    * this is really just backward compatibility, if the SSID
> -    * is set then we use the channel to select the BSS to use
> -    * to connect to instead. If we were connected on another
> -    * channel we disconnected above and reconnect below.
> -    */
> -   if (chan && !wdev->wext.connect.ssid_len) {
> -           struct cfg80211_chan_def chandef = {
> -                   .width = NL80211_CHAN_WIDTH_20_NOHT,
> -                   .center_freq1 = freq,
> -           };
> -
> -           chandef.chan = ieee80211_get_channel(&rdev->wiphy, freq);
> -           if (chandef.chan)
> -                   err = cfg80211_set_monitor_channel(rdev,
> &chandef);
> -           else
> -                   err = -EINVAL;
> -           goto out;
> -   }
> -
>          err = cfg80211_mgd_wext_connect(rdev, wdev);
>    out:
>          wdev_unlock(wdev);

Yeah. Frankly, I don't even understand that comment anymore - if the
interface is in managed mode, why set the monitor channel, it's not
monitoring? And if it's not in managed mode we don't get here.

> 
> 
> I tested the change above: we can now modify the channel/frequency
> when 
> the SSID is not set in managed mode.
> When the SSID is set however iwconfig does not report any error but 
> channel/frequency doesn't change.
> 
> if you think this is acceptable I can submit a patch

I think it looks fine, though writing the commit message may be tricky
:)

johannes
