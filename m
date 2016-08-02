From: Masashi Honma <masashi.honma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 3/3] mac80211: mesh: fixed HT ies in beacon template
Date: Tue, 2 Aug 2016 11:59:04 +0900
Message-ID: <1c2d3cfc-b7fd-c8fd-4f74-14dd3aa3076e@gmail.com>
References: <20160713200755.26839-1-yanivma@ti.com>
 <40a34537-486e-a466-5a7e-e253f19d81c3@gmail.com>
 <1470045822.3389.24.camel@sipsolutions.net>
 <75fef3ce-41a6-5845-e9be-d7ff052a07da@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Yaniv Machani <yanivma-l0cyMroinI0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Meirav Kama <meiravk-l0cyMroinI0@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <75fef3ce-41a6-5845-e9be-d7ff052a07da-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> On 2016年08月01日 19:03, Johannes Berg wrote:
>>
>> But why is that behaviour *correct*? We still support 40 MHz bandwidth
>> things, we just don't use them if we disable HT40.

Or do you mean difference between "hardware capability" and "software 
capability" ?
Do you think IEEE80211_HT_CAP_SUP_WIDTH_20_40 bit should be 1 if the 
hardware capable of HT40 even though HT40 is disabled by 
wpa_supplicant/hostapd ?

I have tested with hostapd. I compared these 2 configfiles.

hostapd0.conf
	ht_capab=[HT40-]
hostapd1.conf
	#ht_capab=[HT40-]

The IEEE80211_HT_CAP_SUP_WIDTH_20_40 bit in beacon was below.

hostapd0.conf
	IEEE80211_HT_CAP_SUP_WIDTH_20_40 = 1
hostapd1.conf
	IEEE80211_HT_CAP_SUP_WIDTH_20_40 = 0

So I think the bit should be zero if disabled also for mesh peer.

Masashi Honma.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
