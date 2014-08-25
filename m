From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next] net: Functions to report space available in
 device TX queues
Date: Mon, 25 Aug 2014 08:18:51 -0700
Message-ID: <CA+mtBx8BJZPOH5zFFdXS0=RwRXqEiCmU-zLSbXLay2JCzyiKOA@mail.gmail.com>
References: <alpine.DEB.2.02.1408241312500.30395@tomh.mtv.corp.google.com>
	<20140824.223529.704627469513160252.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:54136 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932412AbaHYPSw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 11:18:52 -0400
Received: by mail-ie0-f182.google.com with SMTP id y20so9925206ier.41
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 08:18:51 -0700 (PDT)
In-Reply-To: <20140824.223529.704627469513160252.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 24, 2014 at 10:35 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Sun, 24 Aug 2014 13:19:47 -0700 (PDT)
>
>> +/**
>> + *   netdev_avail_queue - report how much space is availble for xmit
>> + *   @dev: network device
>> + *
>> + *   Report the amount of space available in the TX queue in terms of
>> + *   number of bytes. This returns the number of bytes avaiable per
>> + *   DQL. This function may be called without taking the txlock on
>> + *   the device, however in that case the result should be taken as
>> + *   a (strong) hint.
>> + */
>> +static inline int netdev_avail_queue(struct net_device *dev_queue)
>> +{
>> +     return netdev_tx_avail_queue(netdev_get_tx_queue(dev_queue, 0));
>> +}
>> +
>
> This doesn't make any sense, you're only providing queue zero's
> information.
>
It's consistent with the other BQL functions. netdev_*_queue is used
for single queue devices, netdev_tx_*_queue is used for specific
queues in MQ.

> You're passing in a net_device, calling it a "dev_queue" in the
> variable name, the exlicitly using queue zero of that device in the
> netdev_get_tx_queue() call.
>
Cut and paste prototype from netdev_reset_queue which was doing
that... I'll fix it.

> Pretty confusing if you ask me :)
