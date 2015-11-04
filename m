From: Aleksander Morgado <aleksander@aleksander.es>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Wed, 4 Nov 2015 10:31:59 +0100
Message-ID: <CAAP7uc+73KiMFLrZbMM=1yAZZkn-NcVULm0YJd0UJNGBAiq3yw@mail.gmail.com>
References: <1446419775-5215-1-git-send-email-marex@denx.de>
	<CAAP7uc+z==A=VZqYXmsQB4CAuTXvbwefhVyUdud0ES30rbaBsg@mail.gmail.com>
	<CAAP7ucLEN3-_9agX_miLu4n6Vcnbd+jBouMXmEg0x196Q1OZmg@mail.gmail.com>
	<201511031833.27689.marex@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	Vostrikov Andrey <andrey.vostrikov@cogentembedded.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Marek Vasut <marex@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:33645 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754672AbbKDJcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 04:32:00 -0500
Received: by obbww6 with SMTP id ww6so8652974obb.0
        for <netdev@vger.kernel.org>; Wed, 04 Nov 2015 01:31:59 -0800 (PST)
In-Reply-To: <201511031833.27689.marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 3, 2015 at 6:33 PM, Marek Vasut <marex@denx.de> wrote:
> On Tuesday, November 03, 2015 at 05:56:53 PM, Aleksander Morgado wrote:
>> On Tue, Nov 3, 2015 at 5:18 PM, Aleksander Morgado
>>
>> <aleksander@aleksander.es> wrote:
>> > On Tue, Nov 3, 2015 at 4:19 PM, Marek Vasut <marex@denx.de> wrote:
>> >>> , or the duplex TX/RX setup for channels
>> >>> (channels are either RX or TX, not both), or the local
>> >>> echoing/loopback (which wouldn't make much sense for TX-only
>> >>> channels).
>> >>
>> >> Aren't the RX-only/TX-only channels rather a special case ?
>> >
>> > They're actually the only case AFAIK. You've got systems generating
>> > streams of ARINC429 words (e.g. the IRS, the FMC...) and systems that
>> > may consume the streams from multiple independent channels (e.g. the
>> > IFE). I try to think of each logical bus as a single transmitter
>> > broadcasting to multiple receivers.
>>
>> I've re-checked the spec and it does say that there may be systems
>> that act as source (TX) and sink (RX), e.g. DME, VOR or ILS. But in
>> those cases, they will actually have separate TX and RX physical
>> ports.
>
> So, considering that hi3593 which as 2x RX and 1x TX port, what about
> registering one device per port and be done with it ?

Yes, as long as the RX device doesn't accept writing, and the TX
device doesn't accept reading (except for echo I guess, if that ends
up getting included), that would make sense. The kernel will need to
specify somehow the port type clearly.

-- 
Aleksander
https://aleksander.es
