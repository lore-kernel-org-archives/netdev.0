From: Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>
Subject: Re: [PATCH] nl80211: avoid "wdev_id may be used uninitialized"
Date: Thu, 31 Jan 2013 15:21:16 -0700
Message-ID: <510AEE5C.6030303@wwwdotorg.org>
References: <1359504662-23561-1-git-send-email-swarren@wwwdotorg.org>   (sfid-20130130_011118_335925_03B80596) <1359532679.8010.1.camel@jlt4.sipsolutions.net>  <51094F10.60605@wwwdotorg.org> <1359665497.8415.102.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stephen Warren <swarren-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1359665497.8415.102.camel-8Nb76shvtaUJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/31/2013 01:51 PM, Johannes Berg wrote:
> On Wed, 2013-01-30 at 09:49 -0700, Stephen Warren wrote:
>> On 01/30/2013 12:57 AM, Johannes Berg wrote:
>>> On Tue, 2013-01-29 at 17:11 -0700, Stephen Warren wrote:
>>>> From: Stephen Warren <swarren-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
>>>>
>>>> Silence the following:
>>>> net/wireless/nl80211.c: In function '__cfg80211_wdev_from_attrs.clone.119':
>>>> net/wireless/nl80211.c:57:6: warning: 'wdev_id' may be used uninitialized in this function
>>>>
>>>> ... by always initializing wdev_id to zero. I assume that wiphy_idx and
>>>> ifidx are set to -1 for similar reasons, so this change simply propagates
>>>> the same workaround.
>>>>
>>>> In practice, this warning is false, since wdev_id is both set and used
>>>> under the condition if (have_wdev_id). However, at least my compiler
>>>> can't be coerced into realizing this; almost any code between the if
>>>> blocks that set and use the variable causes this warning.
>>>
>>> I don't see this warning? What compiler are you using?
>>
>> I'm using gcc-4.5.3 for ARM. I checked with gcc-4.6.3 and gcc-4.7.2 and
>> indeed I don't see the warning there.
> 
> Interesting. So should I keep it or remove it? I guess in this
> particular instance it doesn't matter all that much. In other cases I'd
> be more against changing it I guess.

It's your call. I guess since it's fixed going forward in gcc, you may
as well drop it though.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
