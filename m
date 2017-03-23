From: Greg Ungerer <gerg@linux-m68k.org>
Subject: Re: [PATCH] net: usbnet: support 64bit stats in qmi_wwan driver
Date: Thu, 23 Mar 2017 21:43:00 +1000
Message-ID: <a2b53c79-2700-05a2-b090-a61fdb3da2b2@linux-m68k.org>
References: <1490232332-19274-1-git-send-email-gerg@linux-m68k.org>
 <87zigcz92k.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: oneukum@suse.com, netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: =?UTF-8?Q?Bj=c3=b8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from icp-osb-irony-out1.external.iinet.net.au ([203.59.1.210]:64988
        "EHLO icp-osb-irony-out1.external.iinet.net.au" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751660AbdCWLnE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 07:43:04 -0400
In-Reply-To: <87zigcz92k.fsf@miraculix.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Bjorn,

On 23/03/17 18:33, Bjørn Mork wrote:
> Greg Ungerer <gerg@linux-m68k.org> writes:
>
>> Add support for the net stats64 counters to the usbnet core and then to
>> the qmi_wwan driver.
>>
>> This is a strait forward addition of 64bit counters for RX and TX packets
>> and byte counts. It is done in the same style as for the other net drivers
>> that support stats64.
>>
>> The bulk of the change is to the usbnet core. Then it is trivial to use
>> that in the qmi_wwan.c driver. It would be very simple to extend this
>> support to other usbnet based drivers.
>>
>> The motivation to add this is that it is not particularly difficult to
>> get the RX and TX byte counts to wrap on 32bit platforms.
>
> You must have a higher quota than me :)

Well, not me personally :-)


> But the patch does not apply to current net-next du to a conflict with
> the ethtool_{get|set}_link_ksettings changes.

Ok, will respin against net-next. I generated this against 4.11-rc2.


>> +void usbnet_get_stats64(struct net_device *net, struct rtnl_link_stats64 *stats)
>> +{
>> +	struct usbnet *dev = netdev_priv(net);
>> +	unsigned int start;
>> +
>> +	netdev_stats_to_stats64(stats, &net->stats);
>> +
>> +	do {
>> +		start = u64_stats_fetch_begin_irq(&dev->stats.syncp);
>> +		stats->rx_packets = dev->stats.rx_packets;
>> +		stats->rx_bytes = dev->stats.rx_bytes;
>> +		stats->tx_packets = dev->stats.tx_packets;
>> +		stats->tx_bytes = dev->stats.tx_bytes;
>> +	} while (u64_stats_fetch_retry_irq(&dev->stats.syncp, start));
>> +}
>> +
>
> And I believe EXPORT_SYMBOL is missing here?

Yep, will fix that too. Thanks.

Regards
Greg
