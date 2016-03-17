From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: [PATCH] net: phy: fix PHY_RUNNING in phy_state_machine
Date: Thu, 17 Mar 2016 16:21:42 +0100
Message-ID: <CAGm1_kt+d7HooYi5JgHvkVYEKO0JLn=1nBgdUd1bSG08+ZLiRg@mail.gmail.com>
References: <1439526220-31458-1-git-send-email-shh.xie@gmail.com>
 <CAGm1_kufFr0SsVwVcABXkL0ABJahiwz4EZ70=ywrtC9Bffbfng@mail.gmail.com>
 <20160316161848.GE2393@lunn.ch> <CAGm1_kuMQrECdb6_NpZ83Nm4RFSn6sQMhMK6392PLyaFFxCs1A@mail.gmail.com>
 <20160316230505.GA18161@lunn.ch> <CAGm1_kv7eia4LPWT5TxUJp1NV+eFZj6gBQc-pHwxbygoF03EYg@mail.gmail.com>
 <20160317134134.GA24913@lunn.ch> <CAGm1_kvJn0Pq38iqOmOcyNpe62EEUmq_s5G2_HXps4Gx+xB_=Q@mail.gmail.com>
 <20160317151240.GD26019@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "shaohui ???" <shh.xie@gmail.com>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Shaohui Xie <Shaohui.Xie@freescale.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>, drivshin@allworx.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f49.google.com ([209.85.213.49]:34100 "EHLO
	mail-vk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031360AbcCQPWD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 11:22:03 -0400
Received: by mail-vk0-f49.google.com with SMTP id e185so106083241vkb.1
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2016 08:22:03 -0700 (PDT)
In-Reply-To: <20160317151240.GD26019@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 17, 2016 at 4:12 PM, Andrew Lunn <andrew@lunn.ch> wrote:
>> After changing cpsw_emac0 entry to:
>>
>> &cpsw_emac0 {
>>         phy-mode = "rmii";
>>         dual_emac_res_vlan = <1>;
>>         fixed-link {
>>                 speed = <100>;
>>                 full-duplex;
>>         };
>> };
>>
>> I've got packets running in both directions.
>
> Great.
>
>> Now I have another problem: I cannot disable ICPlus IP175D ports via
>> SIOCSMIIREG as I could do previously. I get not ioctl errors [1], but
>> the ports are always on.
>>
>> [1] https://github.com/visionsystemsgmbh/libonrisc/blob/master/src/onrisc.c#L83
>
> The MDIO bus is now logically not connected to eth0. Instead you have
> the fixed-link mdio device connected to eth0. So SIOCSMIIREG calls on
> eth0 now try to manipulate the fixed link phys.
>
> However, i think you can still access the MDIO bus, just use eth1 in
> your ioctl call.

Good trick :-)

> You should however consider writing a DSA driver for the switch.

Do you mean SWITCHDEV or is this more or less the same? From time to
time I'm looking at DSA/switchdev patches in the mailing list, but
there seems to be not so many example in kernel. What are the latest
slides, papers aside from Documentation/networking/switchdev.txt?

Yegor
