From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: macb napi strange behavior
Date: Wed, 17 Jun 2015 13:20:45 -0700
Message-ID: <CAGVrzcZxPqyp3CDLc-UQejtVg1QVv5OBuGLQNVSrtfG9H1OUnA@mail.gmail.com>
References: <CAH=tA9FfYh_XSg7y=TujXwuvrjvgg+hOY1j_UOyJNK5mrwaBCw@mail.gmail.com>
 <5581C27C.4040408@ni.com> <CAH=tA9HCqKgSFwMczRJ1hb=Sjb1H5XFg00ddRq=BW+_8OZ0ARQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jaeden Amero <jaeden.amero@ni.com>,
	netdev <netdev@vger.kernel.org>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>,
	Josh Cartwright <joshc@ni.com>
To: Nicolae Rosia <nicolae.rosia@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:34867 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753194AbbFQUV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 16:21:26 -0400
Received: by oiax193 with SMTP id x193so42906887oia.2
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2015 13:21:26 -0700 (PDT)
In-Reply-To: <CAH=tA9HCqKgSFwMczRJ1hb=Sjb1H5XFg00ddRq=BW+_8OZ0ARQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-06-17 12:00 GMT-07:00 Nicolae Rosia <nicolae.rosia@gmail.com>:
> Hi,
>
> On Wed, Jun 17, 2015 at 9:54 PM, Jaeden Amero <jaeden.amero@ni.com> wrote:
>> On 06/17/2015 11:09 AM, Nicolae Rosia wrote:
>> The times we've seen tons of interrupts on Ethernet with interrupts
>> routed through the PL was when the FPGA was unprogrammed (or in the
>> process of being reprogrammed), or was configured with the interrupt
>> line tied to asserted.
>>
>> In the latter case, Linux would eventually stop handling any more
>> interrupts for that port due to the interrupt storm.
>>
> This isn't the case. The FPGA is programmed, and indeed I'm using the
> second MAC routed through PL to SFP.
> The interesting thing is that I'm seeing the exact behavior on the
> other side (another Zynq7 board), with eth0 having lots of interrupts.
> It seems that the interface receiving packets doesn't have a high IRQ
> activity in contrast to the one sending packets.

Typically, NAPI is used at the receive side of the Ethernet NIC/driver
to lower the hard/soft interrupt context switch, although there is
nothing that prevent you to implement a similar scheme for the
transmit side. Usually, for transmit you will be submitting one packet
for transmission and get a completion interrupt, so without interrupt
coalescing (software or hardware) you can end-up with 1 interrupt per
packet transmitted.
-- 
Florian
