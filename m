From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH v3 4/4] USBNET: ax88179_178a: enable tso if usb host
 supports sg dma
Date: Tue, 6 Aug 2013 23:07:20 +0800
Message-ID: <CACVXFVNFPRmhMN5oEU2pr8jKh+93CNswPtCOprG8ZJc4U6iz6g@mail.gmail.com>
References: <1375750370-18194-1-git-send-email-ming.lei@canonical.com>
	<1375750370-18194-5-git-send-email-ming.lei@canonical.com>
	<1375791737.4457.98.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>,
	Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	Grant Grundler <grundler-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1375791737.4457.98.camel@edumazet-glaptop>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 6, 2013 at 8:22 PM, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Tue, 2013-08-06 at 08:52 +0800, Ming Lei wrote:
>> This patch enables 'can_dma_sg' flag for ax88179_178a device
>> if the attached host controller supports building packet from
>> discontinuous buffers(DMA SG is possible), so TSO can be enabled
>> and skb fragment buffers can be passed to usb stack via urb->sg
>> directly.
>>
>> With the patch, system CPU utilization decreased ~50% and throughput
>> increased by ~10% when doing iperf client test on one ARM A15 dual
>> core board.
>>
>
> Nice ;)
>
>>              AX_RXCOE_TCPV6 | AX_RXCOE_UDPV6;
>> @@ -1310,6 +1318,10 @@ static int ax88179_reset(struct usbnet *dev)
>>
>>       dev->net->hw_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
>>                                NETIF_F_RXCSUM;
>> +     if (dev->can_dma_sg) {
>> +             dev->net->features |= NETIF_F_SG | NETIF_F_TSO;
>> +             dev->net->hw_features |= NETIF_F_SG | NETIF_F_TSO;
>> +     }
>>
>
> My concern with setting TSO on reset() is the following :
>
> Admin can disable TSO with
>
> ethtool -K ethX tso off
>
>
> Then, one hour later, or one month later, a reset happens, and this code
> magically re-enables TSO

The reset only happens during open(), and TSO can't be re-enabled magically,
unless the interface is re-opened by Admin.

>
> So, I really think this part should be removed from your patch.

OK, will remove it.


Thanks,
--
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
