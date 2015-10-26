From: Toshiaki Makita <makita.toshiaki-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH v2] net: tso: add support for IPv6
Date: Mon, 26 Oct 2015 17:17:36 +0900
Message-ID: <562DE1A0.9010604@lab.ntt.co.jp>
References: <1445803107-18513-1-git-send-email-emmanuel.grumbach@intel.com>
 <1445803371-19778-1-git-send-email-emmanuel.grumbach@intel.com>
 <562DA5FF.6040307@lab.ntt.co.jp>
 <0BA3FCBA62E2DC44AF3030971E174FB32E8B07E2@hasmsx107.ger.corp.intel.com>
 <562DE0A4.80100@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"egrumbach-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <egrumbach-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: "Grumbach, Emmanuel" <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <562DE0A4.80100-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 2015/10/26 17:13, Toshiaki Makita wrote:
> On 2015/10/26 16:47, Grumbach, Emmanuel wrote:
>> On 10/26/2015 06:03 AM, Toshiaki Makita wrote:
>>> On 2015/10/26 5:02, Emmanuel Grumbach wrote:
>>>> Adding IPv6 for the TSO helper API is trivial:
>>>> * Don't play with the id (which doesn't exist in IPv6)
>>>> * Correctly update the payload_len (don't include the
>>>>   length of the IP header itself)
>>> ...
>>>>  	memcpy(hdr, skb->data, hdr_len);
>>>> -	iph = (struct iphdr *)(hdr + mac_hdr_len);
>>>> -	iph->id = htons(tso->ip_id);
>>>> -	iph->tot_len = htons(size + hdr_len - mac_hdr_len);
>>>> +	if (skb->protocol == htons(ETH_P_IP)) {
>>>
>>> I guess this should be vlan_get_protocol(skb).
>>
>> I truly don't know. I guess we could have VLANs, but I'd need to check
>> how the packet would look like after it exits mac80211.
> 
> I don't know much about mac80211.
> 
> What I see is that mvneta has TSO in vlan_features and it uses
> tso_build_hdr(). When vlan device is used, we cannot access network
> protocol by skb->protocol without HW vlan acceleration.
> So it looks like this change corrupts TSO functionality on mvneta.
> 
>> If we need that, I'll likely do this check once in tso_start() and add a
>> variable to struct tso_t.
> 
> I'm not sure if an additional variable is needed.
> At least, skb_network_offset()/ip_hdr() should correctly handle (skip)
> vlan headers.

Ah, sorry, I misread your suggestion.
Additional variable would make sense to me.

Toshiaki Makita

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
