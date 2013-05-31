From: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Subject: Re: Another try at getting pktgen to work with wifi.
Date: Fri, 31 May 2013 11:51:45 -0700
Message-ID: <51A8F141.5050804@candelatech.com>
References: <51A79E4A.7000609@candelatech.com>   <51A7B049.9090201@openwrt.org> <51A7BA63.4080403@candelatech.com>   <51A857BF.7070008@openwrt.org> <51A8DC1C.1040908@candelatech.com>   (sfid-20130531_192143_291284_FB196B0A) <1370021846.14117.13.camel@jlt4.sipsolutions.net>  <51A8E53E.8030101@candelatech.com> <1370025698.14117.15.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1370025698.14117.15.camel-8Nb76shvtaUJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 05/31/2013 11:41 AM, Johannes Berg wrote:
> On Fri, 2013-05-31 at 11:00 -0700, Ben Greear wrote:
>
>> I think it might be more that the wifi stacks have some specific
>> assumptions about how skb->priority maps to queues and QoS.  If
>> they get out of sync, then the TID mappings and so forth get
>> confused.
>
> What I'm saying though is that I don't see where skb->priority is even
> _used_ in the wifi stack. I can see it getting set, but not used.

ieee80211_downgrade_queue
wme_downgrade_ac // sort of
ieee80211_select_queue_80211 // sort of...seems twiddling skb->priority is more of a by-product here.

cfg80211_classify8021d

>>> Actually that makes it seem like something else should be doing packet
>>> classification, not mac80211 in select_queue()?
>>>
>>> Where is skb->priority actually really used in mac80211? I don't see
>>> much?
>>
>> There's a bit more in net/wireless/util.c, at least (cfg80211_classify8021d, for instance).
>
> But that's pretty much all assignments.

cfg80211_classify8021d uses it to determine the queue in if skb->priority is
set to a special range (hard coded un-documented hack from hell, it appears).

I didn't go looking to find out where those magic values might be set.


>> The mac80211/wme.c uses it.  Some of this is called from the drivers
>> (line 1916 or so of ath9k/xmit.c).
>
> What's called there? I don't see any reason for that to use
> skb->priority?

Ok, I was confused about that..but that *is* the code that pukes if you
have have mis-matched queues like you get with pktgen in upstream kernels...

Thanks,
Ben


-- 
Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Candela Technologies Inc  http://www.candelatech.com

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
