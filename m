From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH V5] bgmac: driver for GBit MAC core on BCMA bus
Date: Tue, 08 Jan 2013 10:37:50 +0100
Message-ID: <50EBE8EE.2030902@openwrt.org>
References: <1357626888-2375-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Joe Perches <joe@perches.com>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:60912 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754532Ab3AHJrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 04:47:35 -0500
Received: by mail-lb0-f169.google.com with SMTP id gk1so233395lbb.0
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2013 01:47:34 -0800 (PST)
In-Reply-To: <1357626888-2375-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Rafal,

Le 01/08/13 07:34, Rafa=C5=82 Mi=C5=82ecki a =C3=A9crit :
> BCMA is a Broadcom specific bus with devices AKA cores. All recent BC=
MA
> based SoCs have gigabit ethernet provided by the GBit MAC core. This
> patch adds driver for such a cores registering itself as a netdev. It
> has been tested on a BCM4706 and BCM4718 chipsets.
>
> In the kernel tree there is already b44 driver which has some common
> things with bgmac, however there are many differences that has led to
> the decision or writing a new driver:
> 1) GBit MAC cores appear on BCMA bus (not SSB as in case of b44)
> 2) There is 64bit DMA engine which differs from 32bit one
> 3) There is no CAM (Content Addressable Memory) in GBit MAC
> 4) We have 4 TX queues on GBit MAC devices (instead of 1)
> 5) Many registers have different addresses/values
> 6) RX header flags are also different
>
> The driver in it's state is functional how, however there is of cours=
e
> place for improvements:
> 1) Supporting more net_device_ops
> 2) SUpporting more ethtool_ops
> 3) Unaligned addressing in DMA
> 4) Writing separated PHY driver

It does not seem like 4) would be too hard to do just right now because=
=20
your PHY functions actually match the semantics of the callbacks you ar=
e=20
supposed to implement for a separate PHY driver. Doing this would make=20
you use phylib in the bgmac driver which is a good thing.

I would be glad if you could do this just now, so we make sure this doe=
s=20
not get lost.

If David is ok with your v5 patch and wants to merge it just now, I am=20
just as happy with that.
--
=46lorian
