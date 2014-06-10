From: Andy Green <andy.green@linaro.org>
Subject: Re: [net-next PATCH 2] net: ethernet driver: Fujitsu OGMA
Date: Tue, 10 Jun 2014 12:04:11 +0800
Message-ID: <CAAfg0W54QT9TrpH4AWOeA9EB-U2zMhvwygQyqDvWYs=WoWdmrA@mail.gmail.com>
References: <20140610010803.18695.88446.stgit@localhost.localdomain>
	<CAGVrzcYrXrsN+_2fA7LUWMFMxnVmv72JMDLyftVx68JS-X7FDg@mail.gmail.com>
	<1402369926.13361.3.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Patch Tracking <patches@linaro.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f177.google.com ([209.85.216.177]:37216 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750790AbaFJEEM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 00:04:12 -0400
Received: by mail-qc0-f177.google.com with SMTP id i17so1645514qcy.36
        for <netdev@vger.kernel.org>; Mon, 09 Jun 2014 21:04:11 -0700 (PDT)
In-Reply-To: <1402369926.13361.3.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10 June 2014 11:12, Joe Perches <joe@perches.com> wrote:
> On Mon, 2014-06-09 at 19:14 -0700, Florian Fainelli wrote:
>> 2014-06-09 18:08 GMT-07:00 Andy Green <andy.green@linaro.org>:
>> > This driver adds support for "ogma", a Fujitsu Semiconductor Ltd IP Gigabit
>> > Ethernet + PHY IP used in a variety of their ARM-based ASICs.
>
> trivial notes:
>
>> > +                                             desc->len * param->entries,
>> > +                                             &desc->deschys_addr, GFP_KERNEL);
>> > +       if (!desc->ring_vaddr) {
>> > +               ret = -ENOMEM;
>> > +               dev_err(priv->dev, "%s: failed to alloc\n", __func__);
>> > +               goto err;
>> > +       }
>> > +
>> > +       memset(desc->ring_vaddr, 0, (u32) desc->len * param->entries);
>> > +       desc->frag = kmalloc(sizeof(*desc->frag) * param->entries,
>> > +                            GFP_NOWAIT);
>>
>> Is not GFP_KERNEL suitable here? If not, cannot you move the
>> allocation to a code-path that is allowed to sleep. e.g the ndo_open()
>> function for instance?
>>
>> > +       if (!desc->frag) {
>> > +               ret = -ENOMEM;
>> > +               dev_err(priv->dev, "%s: failed to alloc\n", __func__);
>> > +               goto err;
>> > +       }
>> > +
>> > +       memset(desc->frag, 0, sizeof(struct ogma_frag_info) * param->entries);
>>
>> kzalloc() does a kmalloc() + memset().
>
> kcalloc does that and checks for overflow too.

OK.

>> > +       if (!desc->priv) {
>> > +               ret = -ENOMEM;
>> > +               dev_err(priv->dev, "%s: failed to alloc priv\n", __func__);
>
> OOM messages are unnecessary as there's a generic one.

OK

>>  +               ret = ogma_get_rx_pkt_data(ndev->priv, OGMA_RING_NRM_RX,
>> > +                                          &rx_pkt_info, &frag, &len, &skb);
>> > +               if (ret == -ENOMEM) {
>> > +                       dev_err(ndev->priv->dev, "%s: rx fail %d",
>> > +                               __func__, ret);
>> > +                       net_device->stats.rx_dropped++;
>> > +                       continue;
>> > +               }
>>
>> The hardware does not tell you whether the packet is oversized, or if
>> there any errors? That looks a little unusual.
>>
>> Use netdev_err() here instead. Or even better netif_err() with
>> rx_status, this comment applies to the entire driver BTW.
>
> That and please terminate all messages with \n to
> avoid possible message interleaving from other modules.

Ah OK, missed it when porting from what was a whole abstracted logging system.

Thanks for the extra points.

-Andy

>
