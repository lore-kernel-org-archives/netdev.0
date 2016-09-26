From: Eric Nelson <eric@nelint.com>
Subject: Re: [PATCH 3/3] net: fec: align IP header in hardware
Date: Mon, 26 Sep 2016 11:39:55 -0700
Message-ID: <4d199f32-092c-1c0a-7a01-6d0d317ef676@nelint.com>
References: <AM4PR0401MB22609D8151C2B63CA7768A1AFFCB0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <1474728139-9335-1-git-send-email-eric@nelint.com>
 <1474728139-9335-4-git-send-email-eric@nelint.com>
 <063D6719AE5E284EB5DD2968C1650D6DB0109865@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>,
        "andrew@lunn.ch" <andrew@lunn.ch>,
        "fugang.duan@nxp.com" <fugang.duan@nxp.com>,
        "otavio@ossystems.com.br" <otavio@ossystems.com.br>,
        "edumazet@google.com" <edumazet@google.com>,
        "troy.kisky@boundarydevices.com" <troy.kisky@boundarydevices.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "u.kleine-koenig@pengutronix.de" <u.kleine-koenig@pengutronix.de>
To: David Laight <David.Laight@ACULAB.COM>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33401 "EHLO
        mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937473AbcIZSj7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 14:39:59 -0400
Received: by mail-pa0-f46.google.com with SMTP id fn2so3263573pad.0
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 11:39:59 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0109865@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On 09/26/2016 02:26 AM, David Laight wrote:
> From: Eric Nelson
>> Sent: 24 September 2016 15:42
>> The FEC receive accelerator (RACC) supports shifting the data payload of
>> received packets by 16-bits, which aligns the payload (IP header) on a
>> 4-byte boundary, which is, if not required, at least strongly suggested
>> by the Linux networking layer.
> ...
>> +		/* align IP header */
>> +		val |= FEC_RACC_SHIFT16;
> 
> I can't help feeling that there needs to be corresponding
> changes to increase the buffer size by 2 (maybe for large mtu)
> and to discard two bytes from the frame length.
> 

In the normal case, the fec driver over-allocates all receive packets to
be of size FEC_ENET_RX_FRSIZE (2048) minus the value of rx_align,
which is either 0x0f (ARM) or 0x03 (PPC).

If the frame length is less than rx_copybreak (typically 256), then
the frame length from the receive buffer descriptor is used to
control the allocation size for a copied buffer, and this will include
the two bytes of padding if RACC_SHIFT16 is set.

> If probably ought to be predicated on NET_IP_ALIGN as well.
> 
Can you elaborate?

Please advise,


Eric
