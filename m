From: Aleksander Morgado <aleksander@aleksander.es>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Tue, 3 Nov 2015 17:10:24 +0100
Message-ID: <CAAP7ucKWT++AbPPA2kvm965JSjsgCm0OMf0-Vnjwe-ck+xjZZQ@mail.gmail.com>
References: <1446419775-5215-1-git-send-email-marex@denx.de>
	<201511021916.18117.marex@denx.de>
	<666821254.20151102231521@cogentembedded.com>
	<201511022125.47892.marex@denx.de>
	<CAAP7uc+3sJRJ9khC6x58ULy2vR8fTCi6gMwtgV_0GAWW49AwLg@mail.gmail.com>
	<56389C38.4080508@pengutronix.de>
	<CAAP7ucLhzqh8+QxYJwx-8-DqSb6YqV0ZXXVGqY=OUUnzAu5EVQ@mail.gmail.com>
	<5638CF74.7030001@pengutronix.de>
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
Received: from mail-oi0-f41.google.com ([209.85.218.41]:34223 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932328AbbKCQKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 11:10:25 -0500
Received: by oies66 with SMTP id s66so11364586oie.1
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 08:10:24 -0800 (PST)
In-Reply-To: <5638CF74.7030001@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> or the duplex TX/RX setup for channels
>> (channels are either RX or TX, not both), or the local
>> echoing/loopback (which wouldn't make much sense for TX-only
>> channels).
>
> Local echo/loopback comes in two flavours:
> - Other socket receive local generate frames, too.
>   This is interesting if you want to merge two ARINC node on single
>   device.

I'd actually love having this for a simulator setup I use where I
currently physically connect cables from a TX channel in one adapter
to a RX channel in another adapter. But I'm not sure there's a
specific real usecase for that apart from testing purposes.

> - Sending socket receives send frame, too. This is useful if you need
>   the feedback that the frame has _really_ been send, not just pushed
>   into the networking stack.

I'd say that a TX error count could be enough here. I'm not sure if
having the echo would justify making the TX channels also
read-capable.

Remember that the actual hardware will have read-only or write-only
channels itself. Each of the real hardware channels exposed in
userspace as interfaces will therefore be read-only or write-only, and
the user will need to know that before using them. An application
wanting to read from channels will need to open and read from the RX
channels only, an application wanting to write to the channels will
need to open and write the TX channels only. The kernel should somehow
specify the type for each of the channels, not to confuse the users.
The virtual interface with both R/W caps doesn't really match what you
would expect in a real interface.

-- 
Aleksander
https://aleksander.es
