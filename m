From: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCHv3] net: usbnet: support 64bit stats in qmi_wwan driver
Date: Fri, 31 Mar 2017 15:35:46 +0200
Message-ID: <24368A4E-6CB6-4646-B5EE-84831CC7F4BD@mork.no>
References: <1490941561-20502-1-git-send-email-gerg@linux-m68k.org> <8737dt25od.fsf@miraculix.mork.no> <cb2bbda4-fddd-ab70-7bdf-4ef43c9e9535@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: oneukum-IBi9RG/b67k@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Greg Ungerer <gerg-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cb2bbda4-fddd-ab70-7bdf-4ef43c9e9535-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On March 31, 2017 3:27:59 PM CEST, Greg Ungerer <gerg@linux-m68k=2Eorg> wr=
ote:
>On 31/03/17 18:48, Bj=C3=B8rn Mork wrote:
>
>>> +void usbnet_get_stats64(struct net_device *net, struct
>rtnl_link_stats64 *stats)
>>> +{
>>> +	struct usbnet *dev =3D netdev_priv(net);
>>> +	unsigned int start;
>>> +	int cpu;
>>> +
>>> +	netdev_stats_to_stats64(stats, &net->stats);
>>> +
>>> +	for_each_possible_cpu(cpu) {
>>> +		struct pcpu_sw_netstats *stats64;
>>> +		u64 rx_packets, rx_bytes;
>>> +		u64 tx_packets, tx_bytes;
>>> +
>>> +		stats64 =3D per_cpu_ptr(dev->stats64, cpu);
>>> +
>>> +		do {
>>> +			start =3D u64_stats_fetch_begin_irq(&stats64->syncp);
>>> +			rx_packets =3D stats64->rx_packets;
>>> +			rx_bytes =3D stats64->rx_bytes;
>>> +			tx_packets =3D stats64->tx_packets;
>>> +			tx_bytes =3D stats64->tx_bytes;
>>> +		} while (u64_stats_fetch_retry_irq(&stats64->syncp, start));
>>> +
>>> +		stats->rx_packets +=3D rx_packets;
>>> +		stats->rx_bytes +=3D rx_bytes;
>>> +		stats->tx_packets +=3D tx_packets;
>>> +		stats->tx_bytes +=3D tx_bytes;
>>> +	}
>>> +}
>>
>> So we only count packets and bytes=2E  No errors=2E  Why?
>
>All stats are counted=2E That call to netdev_stats_to_stats64() transfers
>all other stats struct fields (errors, etc) to the stats64 struct=2E
>No error counts are lost (though they are only stored as 32bits values
>on 32bit machines)=2E


Ah, right=2E Thanks for explaining and sorry for being so slow=2E Then I h=
ave no objection to the patch as it is=2E


Bj=C3=B8rn

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
