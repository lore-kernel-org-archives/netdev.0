From: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Subject: Re: Another try at getting pktgen to work with wifi.
Date: Fri, 31 May 2013 11:00:30 -0700
Message-ID: <51A8E53E.8030101@candelatech.com>
References: <51A79E4A.7000609@candelatech.com>  <51A7B049.9090201@openwrt.org> <51A7BA63.4080403@candelatech.com>  <51A857BF.7070008@openwrt.org> <51A8DC1C.1040908@candelatech.com>  (sfid-20130531_192143_291284_FB196B0A) <1370021846.14117.13.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1370021846.14117.13.camel-8Nb76shvtaUJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 05/31/2013 10:37 AM, Johannes Berg wrote:
> On Fri, 2013-05-31 at 10:21 -0700, Ben Greear wrote:
>
>> Before I go work on this, does anyone have any preference over
>> whether pktgen packets should obey the QoS or the xmit-queue?
>
> That's the core of the problem is that select_queue has the side effect
> of setting skb->priority in mac80211, no? Maybe that side effect needs
> to be removed?

I think it might be more that the wifi stacks have some specific
assumptions about how skb->priority maps to queues and QoS.  If
they get out of sync, then the TID mappings and so forth get
confused.

I actually don't know exactly why pktgen shows this problem,
but it must be because it does direct calls to the hard_start_xmit
method of the netdev when (most?) other paths do dev_queue_xmit
or similar.

> Actually that makes it seem like something else should be doing packet
> classification, not mac80211 in select_queue()?
>
> Where is skb->priority actually really used in mac80211? I don't see
> much?

There's a bit more in net/wireless/util.c, at least (cfg80211_classify8021d, for instance).

The mac80211/wme.c uses it.  Some of this is called from the drivers
(line 1916 or so of ath9k/xmit.c).

It's all a bit convoluted in my opinion, but there may well
be good reasons for it.

I think the network stack in general is not going to want
to bother with mapping QoS to xmit queues, so probably that
has to remain in the wifi stacks somewhere...

Thanks,
Ben


>
> johannes
>


-- 
Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Candela Technologies Inc  http://www.candelatech.com

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
