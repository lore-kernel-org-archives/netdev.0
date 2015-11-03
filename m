From: Aleksander Morgado <aleksander@aleksander.es>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Tue, 3 Nov 2015 16:06:05 +0100
Message-ID: <CAAP7ucLhzqh8+QxYJwx-8-DqSb6YqV0ZXXVGqY=OUUnzAu5EVQ@mail.gmail.com>
References: <1446419775-5215-1-git-send-email-marex@denx.de>
	<201511021916.18117.marex@denx.de>
	<666821254.20151102231521@cogentembedded.com>
	<201511022125.47892.marex@denx.de>
	<CAAP7uc+3sJRJ9khC6x58ULy2vR8fTCi6gMwtgV_0GAWW49AwLg@mail.gmail.com>
	<56389C38.4080508@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Marek Vasut <marex@denx.de>,
	Vostrikov Andrey <andrey.vostrikov@cogentembedded.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:35188 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752196AbbKCPGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 10:06:06 -0500
Received: by oifu63 with SMTP id u63so10266620oif.2
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 07:06:05 -0800 (PST)
In-Reply-To: <56389C38.4080508@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 3, 2015 at 12:36 PM, Marc Kleine-Budde <mkl@pengutronix.de> wrote:
> On 11/03/2015 11:36 AM, Aleksander Morgado wrote:
>> On Mon, Nov 2, 2015 at 9:25 PM, Marek Vasut <marex@denx.de> wrote:
>>>>> I was thinking about this and I mostly agree with you. Obviously, copying
>>>>> the code this way was dumb. On the other hand, ARINC and CAN are two
>>>>> different sort of busses, so I'd propose something slightly different
>>>>> here to avoid confusion and prevent the future extensions (or protocols)
>>>>> from adding unrelated cruft into the CAN stack.
>
>> I'd keep them separate not because ARINC may add unrelated cruft into
>> the CAN stack, but because ARINC is much simpler than CAN already...
>
> What about maintainability? Why take care of two almost identical
> subsystems? With making one stack "simpler" you increase, from my point
> of view, the costs of maintaining even more. If you fix problems in one
> stack you have to adopt the other, too.

If they can share common code, that's fine, that probably can be
worked around if needed. My main issues are actually with all the
behavior that CAN supports and doesn't make much sense in ARINC, like
the complex ID filtering scheme for example (ARINC just requires 256
bits for a minimum filter), or the duplex TX/RX setup for channels
(channels are either RX or TX, not both), or the local
echoing/loopback (which wouldn't make much sense for TX-only
channels). The minimum subset of features required by an ARINC driver
is actually very small. Trying to "fit" ARINC as a subset of CAN may
actually be harder than keeping it separate maintainability wise.
Maybe the issue here is that the original patch is too CAN-like while
it shouldn't be, don't know.

-- 
Aleksander
https://aleksander.es
