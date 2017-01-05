From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: SIOCSIWFREQ while in NL80211_IFTYPE_STATION
Date: Thu, 05 Jan 2017 12:38:21 +0100
Message-ID: <1483616301.4394.6.camel@sipsolutions.net>
References: <685811c3-6247-77fd-8c70-617951886451@linaro.org>
         (sfid-20170105_120230_642426_9BEC69AB)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jorge Ramirez <jorge.ramirez-ortiz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Daniel Lezcano <daniel.lezcano-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <685811c3-6247-77fd-8c70-617951886451-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org> (sfid-20170105_120230_642426_9BEC69AB)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

+linux-wireless, where this should've gone

> I am running a single wlan0 interface in managed mode (no aliases,
> no  other wireless interfaces).
> The association with the AP still hasn't happened.
> 
> I noticed that if trying to change the frequency to one of the valid 
> values, the driver returns EBUSY.
> 
> The call stack is
> cfg80211_wext_siwfreq
> -->cfg80211_mgd_wext_siwfreq
> --->cfg80211_set_monitor_channel (notice call to set 'monitor'
> channel 
> in managed mode)
> ----> fails with EBUSY
> 
> Is therefore the expected behavior to fail under the above
> circumstances 
> (managed mode && single wlan0 interface && no association)?
> And if it is, please could you clarify when would it be valid to
> change the frequency in managed mode?

Frankly, I don't remember - all of this is plastered all over with
backward compatibility hooks etc.

How are you running into this? Why are you even trying to do this? You
really shouldn't use wireless extensions any more.

Also, there shouldn't be much reason to be setting the channel anyway,
unless you want to trigger a connection specifically on that channel,
but then when you use nl80211 you get that included in the CONNECT
command there.

Finally, I suspect that this particular backward compatibility hook
can't really work anyway and could be removed, but I'm not sure that
would have the effect you want either.

johannes
