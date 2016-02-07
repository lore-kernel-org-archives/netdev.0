From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/2] ravb: factor out register bit twiddling code
Date: Sun, 7 Feb 2016 23:58:39 +0300
Message-ID: <56B7AFFF.1060005@cogentembedded.com>
References: <10945950.IO3b17qsSH@wasted.cogentembedded.com>
 <28533982.EPUhcRErZl@wasted.cogentembedded.com>
 <CAMuHMdUSepk+9sdp0tXGoVa4Bz2Xjc8hPbxbyS9PwO78gmLe+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-renesas-soc@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:34236 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932099AbcBGU6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 15:58:43 -0500
Received: by mail-lb0-f177.google.com with SMTP id cw1so73749227lbb.1
        for <netdev@vger.kernel.org>; Sun, 07 Feb 2016 12:58:42 -0800 (PST)
In-Reply-To: <CAMuHMdUSepk+9sdp0tXGoVa4Bz2Xjc8hPbxbyS9PwO78gmLe+w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 02/07/2016 11:48 PM, Geert Uytterhoeven wrote:

>> --- net-next.orig/drivers/net/ethernet/renesas/ravb_main.c
>> +++ net-next/drivers/net/ethernet/renesas/ravb_main.c
>> @@ -2,7 +2,7 @@
>>    *
>>    * Copyright (C) 2014-2015 Renesas Electronics Corporation
>>    * Copyright (C) 2015 Renesas Solutions Corp.
>> - * Copyright (C) 2015 Cogent Embedded, Inc. <source@cogentembedded.com>
>> + * Copyright (C) 2015-2016 Cogent Embedded, Inc. <source@cogentembedded.com>
>>    *
>>    * Based on the SuperH Ethernet driver
>>    *
>> @@ -42,6 +42,12 @@
>>                   NETIF_MSG_RX_ERR | \
>>                   NETIF_MSG_TX_ERR)
>>
>> +void ravb_modify(struct net_device *ndev, enum ravb_reg reg, u32 mask,
>> +                u32 value)
>> +{
>> +       ravb_write(ndev, (ravb_read(ndev, reg) & ~mask) | value, reg);
>> +}
>
> Usually "mask"is used for the bits to keep, not for the bits to clear.
>
> So I'd either
>    1. AND with "mask" instead of "~mask", and update all callers, or
>    2. rename "mask" to "clear", and "value" to "set".

    I'll go with the 2nd option.

> Gr{oetje,eeting}s,
>
>                          Geert

MBR, Sergei
