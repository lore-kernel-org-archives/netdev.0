From: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: regression: tethering fails in 3.5 with iwlwifi
Date: Thu, 20 Sep 2012 14:40:24 +0200
Message-ID: <CANn89iJkXrZPB14KU8xA-Dn8_n=H3J4-R60BTZFV+STF9_ASdA@mail.gmail.com>
References: <1347361823.26457.3.camel@sauron.fi.intel.com>
	<1DC40B07CD6EC041A66726C271A73AE6195AE9C8@IRSMSX102.ger.corp.intel.com>
	<1347631355.5263.19.camel@sauron.fi.intel.com>
	<1347640763.5263.24.camel@sauron.fi.intel.com>
	<1347892887.7112.9.camel@sauron.fi.intel.com>
	<1348142775.2388.10.camel@sauron.fi.intel.com>
	<1348144524.4161.26.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: artem.bityutskiy-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1348144524.4161.26.camel-8Nb76shvtaUJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

OK, but which netif_receive_skb(), as I count 5 occurrences in
net/mac80211/rx.c ?

Instead of skb_linearize() calls

you could try several values of XXX in

pskb_may_pull(skb, XXX)

So that you make sure XXX bytes are available in skb->head, and not
the whole frame.

One you know the limit for XXX, it might give a clue where a
pskb_may_pull(skb, XXX) is missing.

On Thu, Sep 20, 2012 at 2:35 PM, Johannes Berg
<johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
> Hi,
>
>> >             56138f5 iwlwifi: dont pull too much payload in skb head
>> >             3edaf3e mac80211: manage AP netdev carrier state
>>
>> The second patch (AP carrier state) actually exposed a connman issue
>> which I fixed and submitted a connman patch:
>> http://lists.connman.net/pipermail/connman/2012-September/011232.html
>>
>> However, Eric's patch still causes tethering problems to me.
>
>
> Let me recap a bit. Artem is using connman, which sets up the wifi
> interface as part of a bridge. It runs wpa_supplicant to create an AP
> (only AP and mesh mode interfaces can be bridged anyway).
>
>
> Eric, you said:
>
>> I would say some part of the stack assumes a header (I dont know wich
>> one ?) is pulled in skb->head/data, and thats a bug.
>>
>> Always use pskb_may_pull(skb, XXX) to make sure you can access XXX
>> bytes in skb->data
>
> I thought we'd figure out which part of the stack assumes a header, so I
> asked Artem to test a one-line patch which adds "skb_linearize()" before
> "netif_receive_skb()" in mac80211. This makes it work, but I'm not sure
> where after that the bad assumption might be.
>
> johannes
>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
