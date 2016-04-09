From: Petri Gynther <pgynther@google.com>
Subject: Re: [PATCH net-next] net: bcmgenet: add BQL support
Date: Fri, 8 Apr 2016 18:39:55 -0700
Message-ID: <CAGXr9JE8Qp-u4gjm08oB8nXDoQxFM12=Da2=MZbWcZrRXOCi_w@mail.gmail.com>
References: <1459903801-83727-1-git-send-email-pgynther@google.com>
	<20160408.163648.2055481752216023669.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>, opendmb@gmail.com,
	Jaedon Shin <jaedon.shin@gmail.com>
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f51.google.com ([209.85.213.51]:33760 "EHLO
	mail-vk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754049AbcDIBj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 21:39:57 -0400
Received: by mail-vk0-f51.google.com with SMTP id k1so157671763vkb.0
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 18:39:56 -0700 (PDT)
In-Reply-To: <20160408.163648.2055481752216023669.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 8, 2016 at 1:36 PM, David Miller <davem@davemloft.net> wrote:
> From: Petri Gynther <pgynther@google.com>
> Date: Tue,  5 Apr 2016 17:50:01 -0700
>
>> Add Byte Queue Limits (BQL) support to bcmgenet driver.
>>
>> Signed-off-by: Petri Gynther <pgynther@google.com>
>
> As Eric Dumazet indicated, your ->ndo_init() code to reset the queues is
> probably not necessary at all.

I added the netdev_tx_reset_queue(txq) calls to ndo_open() path:
netdev->ndo_open()
  bcmgenet_open()
    bcmgenet_netif_start()
      for all Tx queues:
        netdev_tx_reset_queue(txq)
          clear __QUEUE_STATE_STACK_XOFF
          dql_reset()
      netif_tx_start_all_queues(dev)
        for all Tx queues:
          clear __QUEUE_STATE_DRV_XOFF

So, I think the call to netdev_tx_reset_queue(txq) is in the right
place. It ensures that the Tx queue state is clean when the device is
opened.
