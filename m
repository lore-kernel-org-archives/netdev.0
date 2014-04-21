From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/4] net: systemport: add Broadcom SYSTEMPORT
 Ethernet MAC driver
Date: Mon, 21 Apr 2014 10:51:05 -0700
Message-ID: <CAGVrzcbCLHCgFZGTTtCUaDHLcWh5RvwCj0VyUDK6=8hbPrV2Vg@mail.gmail.com>
References: <1398101494-27959-1-git-send-email-f.fainelli@gmail.com>
 <1398101494-27959-2-git-send-email-f.fainelli@gmail.com> <20140421.134644.1829764866020217667.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:48123 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752779AbaDURvr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 13:51:47 -0400
Received: by mail-qg0-f52.google.com with SMTP id q107so4279506qgd.39
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 10:51:46 -0700 (PDT)
In-Reply-To: <20140421.134644.1829764866020217667.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-04-21 10:46 GMT-07:00 David Miller <davem@davemloft.net>:
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Mon, 21 Apr 2014 10:31:31 -0700
>
>> +#ifdef CONFIG_PHYS_ADDR_T_64BIT
>> +     __raw_writel(upper_32_bits(addr) & DESC_ADDR_HI_MASK,
>> +                             d + DESC_ADDR_HI_STATUS_LEN);
>> +#endif
>
> When a function call spans multiple lines, the arguments on the second
> and subsequent lines need to start exactly at the first column after
> the openning parenthesis.
>
> Please audit and fix this in your entire submission.
>
>> +static int bcm_sysport_set_settings(struct net_device *dev,
>> +                                 struct ethtool_cmd *cmd)
>
> Likewise for functions declarations and definitions.
>
> Also, no NAPI support?  The locking and SKB freeing looks quite baroque
> as a consequence of this.

There is NAPI support for the RX path, transmitted SKBs are freed when
the buffer done interrupt fires, I can certainly rework that if you
feel like it would be better to get per tx-queue NAPI contexts
instead.

Thanks!
-- 
Florian
