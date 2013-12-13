From: "David Laight" <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH 1/1] AX88179_178A: Add FLAG_HW_IPALIGN to determine whether reserving NET_IP_ALIGN bytes for an SKB.
Date: Fri, 13 Dec 2013 10:36:01 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B748A@saturn3.aculab.com>
References: <1386926708-2343-1-git-send-email-freddy@asix.com.tw>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <louis-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>,
	<allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <1386926708-2343-1-git-send-email-freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> From: freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org
...
> -	skb = __netdev_alloc_skb_ip_align(dev->net, size, flags);
> +	if (dev->driver_info->flags & FLAG_HW_IPALIGN)
> +		skb = __netdev_alloc_skb(dev->net, size, flags);
> +	else
> +		skb = __netdev_alloc_skb_ip_align(dev->net, size, flags);

Given the definition:
static inline struct sk_buff *__netdev_alloc_skb_ip_align(struct net_device *dev,
                unsigned int length, gfp_t gfp)
{
        struct sk_buff *skb = __netdev_alloc_skb(dev, length + NET_IP_ALIGN, gfp);

        if (NET_IP_ALIGN && skb)
                skb_reserve(skb, NET_IP_ALIGN);
        return skb;
}

It really ought to be possible to code that without an extra conditional.

	David



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
