From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/2] ethernet: arc: Add support for Rockchip SoC glue
 layer device tree bindings
Date: Fri, 8 Aug 2014 20:21:59 -0700
Message-ID: <CAGVrzcbBNnwD9UHgPweDMCtDJYPdm=j5Gn53-qf2w462hYLodQ@mail.gmail.com>
References: <1407500875-23851-1-git-send-email-romain.perier@gmail.com>
 <1407500875-23851-2-git-send-email-romain.perier@gmail.com> <20140808202830.GA25105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Romain Perier <romain.perier@gmail.com>,
	David Miller <davem@davemloft.net>, heiko@sntech.de,
	max.schwarz@online.de, Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Beniamino Galvani <b.galvani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:53635 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750820AbaHIDWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2014 23:22:40 -0400
Received: by mail-ig0-f174.google.com with SMTP id c1so1955650igq.7
        for <netdev@vger.kernel.org>; Fri, 08 Aug 2014 20:22:39 -0700 (PDT)
In-Reply-To: <20140808202830.GA25105@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-08-08 13:28 GMT-07:00 Beniamino Galvani <b.galvani@gmail.com>:
> On Fri, Aug 08, 2014 at 12:27:55PM +0000, Romain Perier wrote:
>> This patch defines a platform glue layer for Rockchip SoCs which support
>> arc-emac driver. It ensures that regulator for the rmii is on before trying
>> to connect to the ethernet controller. It applies right speed and mode changes
>> to the grf when ethernet settings changes.
>>
>> Signed-off-by: Romain Perier <romain.perier@gmail.com>
>
> (...)
>
>> +struct rockchip_priv_data {
>> +     struct regmap *grf;
>> +     unsigned int grf_offset;
>> +     int interface;
>> +     struct regulator *regulator;
>> +};
>> +
>> +static const unsigned int rockchip_emac_soc_grf_offset[] = {
>> +     0x154, /* rk3066 */
>> +     0x0a4, /* rk3188 */
>> +};
>> +
>> +static const struct of_device_id rockchip_emac_dt_ids[] = {
>> +     { .compatible = "rockchip,rk3066-emac", .data = (void *)rockchip_emac_soc_grf_offset },
>> +     { .compatible = "rockchip,rk3188-emac", .data = (void *)rockchip_emac_soc_grf_offset + 1 },
>
> Hi Romain,
>
> I think you need parenthesis around "rockchip_emac_soc_grf_offset + 1"
> because the cast has higher precedence. Anyway, wouldn't it be simpler
> to avoid the indirection and pass the offset directly in the data field?

I would create separate structures for rk3066 and rk3188, it might
just contain a single member for now which is an offset, but in case
you need to extend it with more parameters, it's much easier, and you
won't have to rework the matching logic. The current use of +1 is
extremely error prone.
--
Florian
