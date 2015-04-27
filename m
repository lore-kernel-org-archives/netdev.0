From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v3] Renesas Ethernet AVB driver
Date: Mon, 27 Apr 2015 09:22:24 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB25CD5@AcuExch.aculab.com>
References: <SIXPR06MB03142A49C392C39922DC2BDA3EE0@SIXPR06MB031.apcprd06.prod.outlook.com>
	<20150422.113654.1169277303695917496.davem@davemloft.net>
	<553804CA.1030605@cogentembedded.com>
 <20150422.164242.2185477513394713122.davem@davemloft.net>
 <553814F0.40405@cogentembedded.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CB24BB5@AcuExch.aculab.com>
 <553A8AF7.2020206@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "mitsuhiro.kimura.kc@renesas.com" <mitsuhiro.kimura.kc@renesas.com>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"galak@codeaurora.org" <galak@codeaurora.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"richardcochran@gmail.com" <richardcochran@gmail.com>,
	"linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>,
	"masaru.nagai.vx@renesas.com" <masaru.nagai.vx@renesas.com>
To: 'Sergei Shtylyov' <sergei.shtylyov@cogentembedded.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.186]:50445 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932369AbbD0JYI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 05:24:08 -0400
In-Reply-To: <553A8AF7.2020206@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov 
> Sent: 24 April 2015 19:27
...
> > If you have ethernet hardware that requires tx or rx buffers to be on
> > 4n boundaries you should send it back as 'not fit for purpose'.
> 
>     The RX buffers can be adjusted with skb_resrerve(), it's only the TX
> buffers that need to be copied...

If the processor can't perform misaligned reads (don't know what is on
your SoC, but I suspect it can't - crossing page boundaries is hard)
then the rx buffer will have to be re-aligned in software.
Even the 'userdata' part will typically end up with an expensive
misaligned buffer copy.

Even on x86 the misaligned transfers are probably measurable.

>     I'm afraid we can't. :-)
>     However, my colleague has suggested a scheme minimizing the copying:
> only up to 3 first bytes need to be copied to the driver's internal buffers,
> the rest can be sent from an skb itself. That would require substantial
> changes to the driver though...

There might be a restriction on the length of buffer fragments.

You might be able to alternate 14 and 1500+ byte receive buffers.
The frame following a slightly overlong one would be 'wrong'.

	David
