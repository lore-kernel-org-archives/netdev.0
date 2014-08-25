From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next] net: Functions to report space available in
 device TX queues
Date: Mon, 25 Aug 2014 12:24:35 -0700
Message-ID: <CAHA+R7ODfX2oQTLE7mciSHyenQuC5MxBR4OCkfQK33qnC9+nxw@mail.gmail.com>
References: <alpine.DEB.2.02.1408241312500.30395@tomh.mtv.corp.google.com>
	<20140824.223529.704627469513160252.davem@davemloft.net>
	<CA+mtBx8BJZPOH5zFFdXS0=RwRXqEiCmU-zLSbXLay2JCzyiKOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:38979 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933223AbaHYTYh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 15:24:37 -0400
Received: by mail-la0-f42.google.com with SMTP id pv20so13941944lab.29
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 12:24:35 -0700 (PDT)
In-Reply-To: <CA+mtBx8BJZPOH5zFFdXS0=RwRXqEiCmU-zLSbXLay2JCzyiKOA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 25, 2014 at 8:18 AM, Tom Herbert <therbert@google.com> wrote:
> On Sun, Aug 24, 2014 at 10:35 PM, David Miller <davem@davemloft.net> wrote:
>> From: Tom Herbert <therbert@google.com>
>> Date: Sun, 24 Aug 2014 13:19:47 -0700 (PDT)
>>
>>> +/**
>>> + *   netdev_avail_queue - report how much space is availble for xmit
>>> + *   @dev: network device
>>> + *
>>> + *   Report the amount of space available in the TX queue in terms of
>>> + *   number of bytes. This returns the number of bytes avaiable per
>>> + *   DQL. This function may be called without taking the txlock on
>>> + *   the device, however in that case the result should be taken as
>>> + *   a (strong) hint.
>>> + */
>>> +static inline int netdev_avail_queue(struct net_device *dev_queue)
>>> +{
>>> +     return netdev_tx_avail_queue(netdev_get_tx_queue(dev_queue, 0));
>>> +}
>>> +
>>
>> This doesn't make any sense, you're only providing queue zero's
>> information.
>>
> It's consistent with the other BQL functions. netdev_*_queue is used
> for single queue devices, netdev_tx_*_queue is used for specific
> queues in MQ.
>

I was also confused by these names when I read the code, it doesn't
make sense to me either. We need some cleanup no matter of your
patch. I will try to do it after your patch is in.
