From: Po-Yu Chuang <ratbert.chuang@gmail.com>
Subject: Re: [PATCH] net: add Faraday FTGMAC100 Gigabit Ethernet driver
Date: Mon, 14 Mar 2011 16:38:08 +0800
Message-ID: <AANLkTi==o78Xq3CxSNpycdPeUUcX6+LYQa=HPqthgbgD@mail.gmail.com>
References: <1299744517-1896-1-git-send-email-ratbert.chuang@gmail.com> <1300047388.2761.48.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Po-Yu Chuang <ratbert@faraday-tech.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:64505 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752286Ab1CNIia convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 04:38:30 -0400
In-Reply-To: <1300047388.2761.48.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Mon, Mar 14, 2011 at 4:16 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le jeudi 10 mars 2011 =C3=A0 16:08 +0800, Po-Yu Chuang a =C3=A9crit :
>> From: Po-Yu Chuang <ratbert@faraday-tech.com>
>>
>> FTGMAC100 Ethernet Media Access Controller supports 10/100/1000 Mbps
>> and MII/GMII. =C2=A0This driver has been working on some ARM/NDS32 S=
oC's
>> including Faraday A369 and Andes AG102.
>
> Hi
>
> It seems very close from drivers/net/ftmac100.c one. Are you sure a
> factorization is not possible ?

=46irst, the registers and descriptors of FTGMAC100 are not backward
compatible to FTMAC100.

Second, FTGMAC100 HW has some features new to FTMAC100
(jumbo packet, checksum offload... etc.) and not all of them are suppor=
ted
in the current version. For example, NETIF_F_SG support might be the ne=
xt
step to improve.

IMHO, it will be easier for me to maintain them and to add new features=
 to
=46TGMAC100 driver if we separate these two drivers. How do you think?

> BTW, it seems I missed the fact that ftmac100_alloc_rx_page() used a
> GFP_KERNEL allocation, while its called from softirq context (from
> ftmac100_rx_packet())

Tested. Thank you.

> Same problem of course in this Gigabit driver.

Will fix it.

Best regards,
Po-Yu Chuang
