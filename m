From: Eric Nelson <eric@nelint.com>
Subject: Re: Alignment issues with freescale FEC driver
Date: Fri, 23 Sep 2016 11:35:17 -0700
Message-ID: <bc19d934-f50b-50d6-0f4f-ecfcb8a2a1c9@nelint.com>
References: <troy.kisky@boundarydevices.com>
 <02afb707-65de-5101-a79b-355929c4e00b@nelint.com>
 <CANn89iLb+QJu+MYh859oAAjcLCsKRpBbzVf43yOdq+HJVtZDpQ@mail.gmail.com>
 <5ee28ee0-cf0c-bdab-1271-f17755365c13@nelint.com>
 <0fe7a310-2d2f-4fca-d698-85d66122d91c@nelint.com>
 <20160923181301.GD22965@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        Fugang Duan <fugang.duan@nxp.com>,
        Otavio Salvador <otavio@ossystems.com.br>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Troy Kisky <troy.kisky@boundarydevices.com>,
        rmk+kernel@arm.linux.org.uk, Simone <cjb.sw.nospam@gmail.com>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33431 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1035314AbcIWSfT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 14:35:19 -0400
Received: by mail-pf0-f181.google.com with SMTP id 21so44486551pfy.0
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 11:35:19 -0700 (PDT)
In-Reply-To: <20160923181301.GD22965@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Andrew.

On 09/23/2016 11:13 AM, Andrew Lunn wrote:
>> Since the hardware requires longword alignment for its' DMA transfers,
>> aligning the IP header will require a memcpy, right?
> 
> The vf610 FEC has an SHIFT16 bit in register ENETx_TACC, which inserts
> two padding bits on transmit. ENETx_RACC has the same.
> 
> What about your hardware?
> 

You got me with the RTFM!

>From the i.MX6DQ reference manual, bit 7 of ENET_RACC says this:

"RX FIFO Shift-16

When this field is set, the actual frame data starts at bit 16 of the first
word read from the RX FIFO aligning the Ethernet payload on a
32-bit boundary."

Same for the i.MX6UL.

I'm not sure what it will take to use this, but it seems to be exactly
what we're looking for.
