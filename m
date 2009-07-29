From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: Re: [PATCH] pxaficp-ir - remove incorrect net_device_ops
Date: Wed, 29 Jul 2009 15:16:25 +0400
Message-ID: <a4423d670907290416h4a0796c2s665d3f8ca0755e67@mail.gmail.com>
References: <200907240257.10906.marek.vasut@gmail.com>
	 <4A6E69FA.9010903@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marek Vasut <marek.vasut@gmail.com>,
	linux-arm-kernel@lists.arm.linux.org.uk,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	samuel@sortiz.org, netdev@vger.kernel.org
To: Eric Miao <eric.y.miao@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:64974 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753519AbZG2LQ0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 07:16:26 -0400
Received: by ewy26 with SMTP id 26so732887ewy.37
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2009 04:16:25 -0700 (PDT)
In-Reply-To: <4A6E69FA.9010903@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/7/28 Eric Miao <eric.y.miao@gmail.com>:
> Marek Vasut wrote:
>> Hi!
>>
>> This patch fixes broken pxaficp-ir. The problem was in incorrect
>> net_device_ops being specified which prevented the driver from
>> operating. The symptoms were:
>> =C2=A0- failing ifconfig for IrLAN, resulting in
>> =C2=A0 =C2=A0 =C2=A0 SIOCSIFFLAGS: Cannot assign requested address
>> =C2=A0- irattach working for IrCOMM, but the port stayed disabled
>>
>> Moreover this patch corrects missing sysfs device link.
>>
>> btw. guys, be honest, when did you last tested pxaficp-ir on real ha=
rdware? ;-)
>>
>
> Well, this seems to be brought by the net_device_ops change, which se=
ems
> to happen silently without any of us being notified.
>
> OK, netdev and Alex are copied, so that we can look into this issue a=
 bit
> deeper:
>
> 1. it looks to me that SIOCSIFFLAGS actually returned -EADDRNOTAVAIL,=
 which
> =C2=A0 is likely caused by eth_validate_addr, the default eth_addr co=
mes with
> =C2=A0 irda should be "00:00:00:00:00:00" if not explicitly specified=
 (kzalloc),
> =C2=A0 and this should be the problem, solution ? =C2=A0Either give a=
 valid address
> =C2=A0 to the irda net_device or remove this 'ndo_validate_addr'. And=
 which is
> =C2=A0 a correct fix will impact on the .ndo_set_mac_address
>
> 2. '.ndo_change_mtu' ? It looks to me that Irda device doesn't care t=
oo much
> =C2=A0 about the MTU, eth_change_mtu is supposed to work just fine an=
d not to
> =C2=A0 cause any side effects, and may just benefit later irda device=
 drivers if
> =C2=A0 there is a weird device happens to care about MTU
>
> - eric
>
> Marek's original patch in attachment.
>

Sorry about that and thanks.
Then we should fix the rest of irda drivers in the same way.
