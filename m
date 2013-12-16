From: Freddy Xin <freddy@asix.com.tw>
Subject: Re: [PATCH 1/1] AX88179_178A: Add FLAG_HW_IPALIGN to determine whether
 reserving NET_IP_ALIGN bytes for an SKB.
Date: Mon, 16 Dec 2013 14:54:32 +0800
Message-ID: <52AEA3A8.2020906@asix.com.tw>
References: <1386926708-2343-1-git-send-email-freddy@asix.com.tw> <AE90C24D6B3A694183C094C60CF0A2F6026B748A@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: David Laight <David.Laight@ACULAB.COM>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org, louis@asix.com.tw, allan@asix.com.tw
Return-path: <netdev-owner@vger.kernel.org>
Received: from asix.com.tw ([113.196.140.82]:51244 "EHLO freebsd1.asix.com.tw"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750813Ab3LPHXq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 02:23:46 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B748A@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013=E5=B9=B412=E6=9C=8813=E6=97=A5 18:36, David Laight wrote:
>> From: freddy@asix.com.tw
> ...
>> -	skb =3D __netdev_alloc_skb_ip_align(dev->net, size, flags);
>> +	if (dev->driver_info->flags & FLAG_HW_IPALIGN)
>> +		skb =3D __netdev_alloc_skb(dev->net, size, flags);
>> +	else
>> +		skb =3D __netdev_alloc_skb_ip_align(dev->net, size, flags);
> Given the definition:
> static inline struct sk_buff *__netdev_alloc_skb_ip_align(struct net_=
device *dev,
>                  unsigned int length, gfp_t gfp)
> {
>          struct sk_buff *skb =3D __netdev_alloc_skb(dev, length + NET=
_IP_ALIGN, gfp);
>
>          if (NET_IP_ALIGN && skb)
>                  skb_reserve(skb, NET_IP_ALIGN);
>          return skb;
> }
>
> It really ought to be possible to code that without an extra conditio=
nal.
>
> 	David
>
>
>
>
The AX88179_178A driver do need to know the value of NET_IP_ALIGN
to determine whether enabling the feature that makes IP header align
on a dword-aligned address, but according to the comments from David
Miller, I need to consider all situations, not just for the case that
NET_IP_ALIGN is zero, so the condition added in rx_submit is just used =
to
determine whether reserving NET_IP_ALIGN bytes for each SKB.

=46reddy
