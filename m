From: "Tomas Winkler" <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Bugme-new] [Bug 11144] New: dhcp doesn't work with iwl4965
Date: Thu, 24 Jul 2008 14:35:46 +0300
Message-ID: <1ba2fa240807240435g36daa80at254144afffc39c32@mail.gmail.com>
References: <4887550B.2070704@tvcablenet.be> <4887555A.30605@trash.net>
	 <48875B8C.2090800@trash.net>
	 <20080723.142147.61941255.davem@davemloft.net>
	 <48884451.1090703@trash.net>
	 <1ba2fa240807240317g15f6ba84h91b513cce75975e9@mail.gmail.com>
	 <48885743.8030505@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	francois.valenduc-bmtTS95sd5BUM80lpFwj4w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jussi.kivilinna-E01nCVcF24I@public.gmane.org
To: "Patrick McHardy" <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <48885743.8030505-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 24, 2008 at 1:19 PM, Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org> wrote:
> Tomas Winkler wrote:
>>
>> On Thu, Jul 24, 2008 at 11:58 AM, Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org> wrote:
>>>
>>> David Miller wrote:
>>>>
>>>> From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
>>>> Date: Wed, 23 Jul 2008 18:25:48 +0200
>>>>
>>>>> We can't fit them into the cb together, I don't see a way to
>>>>> shrink ieee80211_tx_info.
>>>>>
>>>>> Maybe one of the wireless folks can suggest something? Is it
>>>>> really necessary to pass the full struct ieee80211_tx_info
>>>>> through the qdisc layer, or could the struct be split? It
>>>>> needs to find a way to co-exist peacefully with qdiscs'
>>>>> skb->cb usage.
>>>>
>>>> This is another area that got mangled up in the ->select_queue()
>>>> conversion of the WME bits, but in another aspect this problem
>>>> existed beforehand as well.
>>>>
>>>> Specifically, when RX packets get requeued out to transmit in
>>>> the code in net/mac80211/rx.c that resends packets back out the
>>>> wireless device by setting a bit in the SKB CB then calling
>>>> dev_queue_xmit().
>>>>
>>>> That's completely illegal :-)
>>>
>>> It seems its doing even more illegal things that were also
>>> present previously. The ieee80211_master_start_xmit function
>>> expects to get a valid IEEE80211_SKB_CB, which means it
>>> expects it to survive through the entire qdisc layer. I'm
>>> not sure how packets get to the master device from the
>>> subifs though, so I might be wrong.
>>>
>> Isn't this time to make 802.11 native?
>
>
> You mean by making these things real skb members? I hope you're
> not talking about the entire 48 bytes? :)

I mean elevating 802.11 header to 802.3 level. Not doing 802.3 ->
802.11 translation where not needed.
Tomas
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
