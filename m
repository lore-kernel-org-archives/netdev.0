From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 1/3] Add LAN743X driver
Date: Fri, 11 Aug 2017 16:05:32 -0700
Message-ID: <20170811160532.6a35b3b2@xeon-e3>
References: <90A7E81AE28BAE4CBDDB3B35F187D264406F603F@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <UNGLinuxDriver@microchip.com>
To: <Bryan.Whitehead@microchip.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34841 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753127AbdHKXFk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 19:05:40 -0400
Received: by mail-pf0-f179.google.com with SMTP id t86so21034382pfe.2
        for <netdev@vger.kernel.org>; Fri, 11 Aug 2017 16:05:39 -0700 (PDT)
In-Reply-To: <90A7E81AE28BAE4CBDDB3B35F187D264406F603F@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Aug 2017 19:47:57 +0000
<Bryan.Whitehead@microchip.com> wrote:

> +
> +static struct net_device_stats *mac_get_stats(struct lan743x_adapter *adapter)
> +{
> +	struct lan743x_mac *mac = &adapter->mac;
> +
> +	memset(&mac->statistics, 0, sizeof(mac->statistics));
> +	mac->statistics.rx_packets = lan743x_csr_read(adapter,
> +						      STAT_RX_TOTAL_FRAMES);
> +	mac->statistics.tx_packets = lan743x_csr_read(adapter,
> +						      STAT_TX_TOTAL_FRAMES);
> +	return &mac->statistics;
> +}

The statistics code here is confused.
You are already counting rx_packets in software in napi_poll
Then you get values from MAC. One or the other?
There are two copies of stats, one in netdev and other in your mac structure.

Also what about byte and error counts?

If possible implement 64 bit get_stats64 instead.
