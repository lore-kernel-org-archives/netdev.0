From: Aleksander Morgado <aleksander@aleksander.es>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Wed, 4 Nov 2015 10:51:25 +0100
Message-ID: <CAAP7uc+ytdWWDQU0eFozK1d=HkQ5YnvOqNbLQcjdy9qdJbgKYQ@mail.gmail.com>
References: <1446419775-5215-1-git-send-email-marex@denx.de>
	<201511021916.18117.marex@denx.de>
	<666821254.20151102231521@cogentembedded.com>
	<201511022125.47892.marex@denx.de>
	<CAAP7uc+3sJRJ9khC6x58ULy2vR8fTCi6gMwtgV_0GAWW49AwLg@mail.gmail.com>
	<5638E86A.4090907@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Marek Vasut <marex@denx.de>,
	Vostrikov Andrey <andrey.vostrikov@cogentembedded.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:36797 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932303AbbKDJv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 04:51:26 -0500
Received: by oiww189 with SMTP id w189so1447683oiw.3
        for <netdev@vger.kernel.org>; Wed, 04 Nov 2015 01:51:25 -0800 (PST)
In-Reply-To: <5638E86A.4090907@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 3, 2015 at 6:01 PM, Oliver Hartkopp <socketcan@hartkopp.net> wrote:
>> Unrelated to all this, another key point in ARINC is the timing for
>> each label when transmitting. The common case you get is different
>> labels being sent continuously with a given rate for each. E.g. labels
>> 310 and 311 every 80ms, label 312 every 120ms and so on. I'm not sure
>> the HOLT chips have any specific way of configuring this, but I've
>> seen some USB devices which actually have APIs to say e.g. "send label
>> 310 every 80ms" and then you can just update the value being sent
>> without needing to take care of the TX rate. I'd have loved to see
>> that instead of the complex filtering :) I know this is way too much
>> for the generic kernel driver, though, so just a heads up of how this
>> usually works.
>>
>
> The CAN stack already has a solution for this.
>
> The CAN_BCM socket is a programmable (content) filter for cyclic messages
> which are common in automotive setups to detect timeouts in cyclic messages
> (sender fails).
>
> An the best thing: You can use the Linux internal high-res timers to send
> messages - just by creating a TX_SETUP configuration for the BCM.
>
> Read this:
> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/tree/Documentation/networking/can.txt?h=linux-4.2.y#n634
>
> Just one more reason to use PF_CAN :-)

This setup is actually very interesting for ARINC transmitters, indeed.


-- 
Aleksander
https://aleksander.es
