From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [Uclinux-dist-devel] [PATCH 1/5] netdev: bfin_mac: Blackfin EMAC
	interrupt may not be shared
Date: Fri, 29 May 2009 18:13:02 -0400
Message-ID: <8bd0f97a0905291513m780898e9j6bd4c0b3b9ae8528@mail.gmail.com>
References: <8bd0f97a0905290422x502d6006yb05ebe231b05e9bc@mail.gmail.com>
	 <20090529.042817.176293351.davem@davemloft.net>
	 <8bd0f97a0905290445x3b0829f3h657fec534f290c7f@mail.gmail.com>
	 <20090529.150928.239765896.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael.Hennerich@analog.com, netdev@vger.kernel.org,
	uclinux-dist-devel@blackfin.uclinux.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f214.google.com ([209.85.217.214]:35577 "EHLO
	mail-gx0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751929AbZE2WNB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 18:13:01 -0400
Received: by gxk10 with SMTP id 10so10920642gxk.13
        for <netdev@vger.kernel.org>; Fri, 29 May 2009 15:13:02 -0700 (PDT)
In-Reply-To: <20090529.150928.239765896.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 29, 2009 at 18:09, David Miller wrote:
> From: Mike Frysinger <vapier.adi@gmail.com>
>> On Fri, May 29, 2009 at 07:28, David Miller wrote:
>>> From: Mike Frysinger <vapier.adi@gmail.com>
>>>> why implement extra over head in an interrupt handler to support a=
n
>>>> operating mode the hardware can never support.
>>>
>>> What overhead? =C2=A0It should be pretty easy to see if the device
>>> is really indicating an interrupt or not :-)
>>
>> which would involve reading system mmrs which are clocked at the
>> system frequency and thus make the core stall
>
> And the core doesn't stall reading in these cache lines that the chip
> has just DMA'd to?

the difference is that one of these is required in order for anything
to get done and the other is always useless noise.  also, the Blackfin
core does do speculative data fetching on external memory, but not
MMRs, so the stalling due to the data cache line fills will be
mitigated unlike the useless MMR reads.
-mike
