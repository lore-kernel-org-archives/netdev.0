From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v3] Renesas Ethernet AVB driver
Date: Fri, 24 Apr 2015 09:03:42 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB24BB5@AcuExch.aculab.com>
References: <SIXPR06MB03142A49C392C39922DC2BDA3EE0@SIXPR06MB031.apcprd06.prod.outlook.com>
	<20150422.113654.1169277303695917496.davem@davemloft.net>
	<553804CA.1030605@cogentembedded.com>
 <20150422.164242.2185477513394713122.davem@davemloft.net>
 <553814F0.40405@cogentembedded.com>
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
Received: from smtp-out4.electric.net ([192.162.216.181]:59413 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934577AbbDXJFO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 05:05:14 -0400
In-Reply-To: <553814F0.40405@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov
> Sent: 22 April 2015 22:39
> On 04/22/2015 11:42 PM, David Miller wrote:
> 
> >>     Hmm, I've been digging in the net core, and was unable to see where TX
> >>     skb's get their NET_IP_ALIGN bytes reserved. Have I missed something?
> >>     Probably need to print out skb's fields...
> 
> > NET_IP_ALIGN is for receive, not transmit.
> 
>     But when I print 'skb->data' from the ndo_start_xmit() method (in the
> 'sh_eth' driver), all addresses end with 2, so it looks like NET_IP_ALIGN gets
> added somewhere...

For a locally generated message:
The TCP userdata is likely to be 4 byte aligned.
The TCP and IP headers are multiples of 4 bytes.
The MAC header is 14 bytes.
So you end up with a buffer that starts on a 4n+2 boundary or an initial
short fragment that is 4n+2 bytes long.

If a message is being forwarded the alignment probably depends on where
it came from.

If you have ethernet hardware that requires tx or rx buffers to be on
4n boundaries you should send it back as 'not fit for purpose'.

	David
