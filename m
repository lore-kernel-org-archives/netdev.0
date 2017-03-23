From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] net: usbnet: support 64bit stats in qmi_wwan driver
Date: Thu, 23 Mar 2017 09:33:23 +0100
Message-ID: <87zigcz92k.fsf@miraculix.mork.no>
References: <1490232332-19274-1-git-send-email-gerg@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: oneukum@suse.com, netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Greg Ungerer <gerg@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:54543 "EHLO canardo.mork.no"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753108AbdCWIeO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Mar 2017 04:34:14 -0400
In-Reply-To: <1490232332-19274-1-git-send-email-gerg@linux-m68k.org> (Greg
        Ungerer's message of "Thu, 23 Mar 2017 11:25:32 +1000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg Ungerer <gerg@linux-m68k.org> writes:

> Add support for the net stats64 counters to the usbnet core and then to
> the qmi_wwan driver.
>
> This is a strait forward addition of 64bit counters for RX and TX packets
> and byte counts. It is done in the same style as for the other net drivers
> that support stats64.
>
> The bulk of the change is to the usbnet core. Then it is trivial to use
> that in the qmi_wwan.c driver. It would be very simple to extend this
> support to other usbnet based drivers.
>
> The motivation to add this is that it is not particularly difficult to
> get the RX and TX byte counts to wrap on 32bit platforms.

You must have a higher quota than me :)

But the patch does not apply to current net-next du to a conflict with
the ethtool_{get|set}_link_ksettings changes.


> +void usbnet_get_stats64(struct net_device *net, struct rtnl_link_stats64=
 *stats)
> +{
> +	struct usbnet *dev =3D netdev_priv(net);
> +	unsigned int start;
> +
> +	netdev_stats_to_stats64(stats, &net->stats);
> +
> +	do {
> +		start =3D u64_stats_fetch_begin_irq(&dev->stats.syncp);
> +		stats->rx_packets =3D dev->stats.rx_packets;
> +		stats->rx_bytes =3D dev->stats.rx_bytes;
> +		stats->tx_packets =3D dev->stats.tx_packets;
> +		stats->tx_bytes =3D dev->stats.tx_bytes;
> +	} while (u64_stats_fetch_retry_irq(&dev->stats.syncp, start));
> +}
> +

And I believe EXPORT_SYMBOL is missing here?



Bj=C3=B8rn
