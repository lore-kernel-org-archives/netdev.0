From: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Subject: Re: Another try at getting pktgen to work with wifi.
Date: Fri, 31 May 2013 10:21:32 -0700
Message-ID: <51A8DC1C.1040908@candelatech.com>
References: <51A79E4A.7000609@candelatech.com> <51A7B049.9090201@openwrt.org> <51A7BA63.4080403@candelatech.com> <51A857BF.7070008@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <51A857BF.7070008-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 05/31/2013 12:56 AM, Felix Fietkau wrote:
> On 2013-05-30 10:45 PM, Ben Greear wrote:
>> On 05/30/2013 01:02 PM, Felix Fietkau wrote:
>>> On 2013-05-30 8:45 PM, Ben Greear wrote:
>>>> I'm trying to come up with a more acceptable patch to the problem discussed a few years
>>>> ago:
>>>>
>>>> http://thread.gmane.org/gmane.linux.kernel.wireless.general/64582/focus=64626
>>>>
>>>> The patch below appears to work as expected.  In pktgen, you just have to set
>>>> the QoS to whatever value matches the queue you need.
>>>>
>>>> This seem reasonable?
>>> Why do you adjust the queue mapping instead of the skb priority? In that
>>> other thread you mentioned that pktgen should be able to control the
>>> queue, yet here you're taking queue control away from it for tx on mac80211.
>>
>> I was having trouble getting it to work, but I was trying it at
>> a different place in the code when I was hacking on it...
>>
>> Do you think I'd just need to adjust skb->priority in the
>> same spot in the code, or is there more to it?
> I think that could work.

[added netdev to CC list]

Before I go work on this, does anyone have any preference over
whether pktgen packets should obey the QoS or the xmit-queue?

Currently, the kernel is effectively broken, and has been for years,
so probably no one has ever used pktgen with wifi devices.

As it turns out, mapping QoS appears to work best for my own needs,
but I can also try using the skb->priority as Felix suggests.

If no one cares, then I'd prefer to stick with the QoS method I posted
recently, and ignore the xmit-queue that pktgen might select.

Thanks,
Ben

>
> - Felix
>


-- 
Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Candela Technologies Inc  http://www.candelatech.com

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
