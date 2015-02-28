From: Eyal Birger <eyal.birger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v2 4/7] net: packet: use skb->dev as storage for
 skb orig len instead of skb->cb[]
Date: Sat, 28 Feb 2015 21:39:34 +0200
Message-ID: <CAHsH6Guq33N755dcuNEmzgP06O=PBdy2Tzt5vSr-iRFoj4uGtw@mail.gmail.com>
References: <1424977624-649-1-git-send-email-eyal.birger@gmail.com>
	<1424977624-649-5-git-send-email-eyal.birger@gmail.com>
	<20150228.142135.470339626705046722.davem@davemloft.net>
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
In-Reply-To: <20150228.142135.470339626705046722.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 28, 2015 at 9:21 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> From: Eyal Birger <eyal.birger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Thu, 26 Feb 2015 21:07:01 +0200
>
>> As part of an effort to move skb->dropcount to skb->cb[], 4 bytes
>> of additional room are needed in skb->cb[] in packet sockets.
>>
>> Store the skb original length in skb->dev instead of skb->cb[] for
>> this purpose.
>>
>> Signed-off-by: Eyal Birger <eyal.birger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>
> I'm a little confused, why is this even needed?
>
> packet_skb_cb is 24 bytes by my calculations, which is much
> smaller than the cb[] size which is 48 bytes.

Note the BUILD_BUG_ON in packet_rcv().

packet_skb_cb may contain an address as large as MAX_ADDR_LEN (32)
Therefore the required space is sizeof(packet_skb_cb) + MAX_ADDR_LEN - 8
which is 48 bytes before this change.

Regards,
Eyal.
