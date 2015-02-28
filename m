From: Eyal Birger <eyal.birger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v2 4/7] net: packet: use skb->dev as storage for
 skb orig len instead of skb->cb[]
Date: Sat, 28 Feb 2015 22:38:04 +0200
Message-ID: <CAHsH6GvvQxHbt4JJrotn3y=BG172Wbw4NrMD+gTUA_R=jbPDTw@mail.gmail.com>
References: <1424977624-649-5-git-send-email-eyal.birger@gmail.com>
	<20150228.142135.470339626705046722.davem@davemloft.net>
	<CAHsH6Guq33N755dcuNEmzgP06O=PBdy2Tzt5vSr-iRFoj4uGtw@mail.gmail.com>
	<20150228.150830.1726900309943339124.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Shmulik Ladkani <shmulik.ladkani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150228.150830.1726900309943339124.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 28, 2015 at 10:08 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> From: Eyal Birger <eyal.birger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Sat, 28 Feb 2015 21:39:34 +0200
>
>> On Sat, Feb 28, 2015 at 9:21 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
>>> From: Eyal Birger <eyal.birger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>> Date: Thu, 26 Feb 2015 21:07:01 +0200
>>>
>>>> As part of an effort to move skb->dropcount to skb->cb[], 4 bytes
>>>> of additional room are needed in skb->cb[] in packet sockets.
>>>>
>>>> Store the skb original length in skb->dev instead of skb->cb[] for
>>>> this purpose.
>>>>
>>>> Signed-off-by: Eyal Birger <eyal.birger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>>
>>> I'm a little confused, why is this even needed?
>>>
>>> packet_skb_cb is 24 bytes by my calculations, which is much
>>> smaller than the cb[] size which is 48 bytes.
>>
>> Note the BUILD_BUG_ON in packet_rcv().
>>
>> packet_skb_cb may contain an address as large as MAX_ADDR_LEN (32)
>> Therefore the required space is sizeof(packet_skb_cb) + MAX_ADDR_LEN - 8
>> which is 48 bytes before this change.
>
> So let's take a step back.
>
> What link layer we support has 32-byte hardware addresses?

The largest one I've been hinted of is INFINIBAND_ALEN which is 20 bytes.

> If the answer is lower than 32, we should use that value instead.

Won't that value become the 'real' MAX_ADDR_LEN in that case?

My concern is that any value I pick based on the existing implementations
would need to be adjusted come a protocol with a larger address length.

Also, I would have to assert the available amount of space at run-time as
the address length is provided by a call to dev_parse_header() instead of
using a build-time assert.

Regards,
Eyal.
