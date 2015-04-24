From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3] Renesas Ethernet AVB driver
Date: Fri, 24 Apr 2015 21:27:03 +0300
Message-ID: <553A8AF7.2020206@cogentembedded.com>
References: <SIXPR06MB03142A49C392C39922DC2BDA3EE0@SIXPR06MB031.apcprd06.prod.outlook.com>	<20150422.113654.1169277303695917496.davem@davemloft.net>	<553804CA.1030605@cogentembedded.com> <20150422.164242.2185477513394713122.davem@davemloft.net> <553814F0.40405@cogentembedded.com> <063D6719AE5E284EB5DD2968C1650D6D1CB24BB5@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
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
To: David Laight <David.Laight@ACULAB.COM>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:35201 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755669AbbDXS1J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 14:27:09 -0400
Received: by labbd9 with SMTP id bd9so41317863lab.2
        for <netdev@vger.kernel.org>; Fri, 24 Apr 2015 11:27:07 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB24BB5@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/24/2015 12:03 PM, David Laight wrote:

>> Sent: 22 April 2015 22:39
>> On 04/22/2015 11:42 PM, David Miller wrote:

>>>>      Hmm, I've been digging in the net core, and was unable to see where TX
>>>>      skb's get their NET_IP_ALIGN bytes reserved. Have I missed something?
>>>>      Probably need to print out skb's fields...

>>> NET_IP_ALIGN is for receive, not transmit.

>>      But when I print 'skb->data' from the ndo_start_xmit() method (in the
>> 'sh_eth' driver), all addresses end with 2, so it looks like NET_IP_ALIGN gets
>> added somewhere...

> For a locally generated message:
> The TCP userdata is likely to be 4 byte aligned.
> The TCP and IP headers are multiples of 4 bytes.
> The MAC header is 14 bytes.
> So you end up with a buffer that starts on a 4n+2 boundary or an initial
> short fragment that is 4n+2 bytes long.

> If a message is being forwarded the alignment probably depends on where
> it came from.

    Thanks for the detailed reply, though it came a bit late. :-)

> If you have ethernet hardware that requires tx or rx buffers to be on

    The RX buffers can be adjusted with skb_resrerve(), it's only the TX 
buffers that need to be copied...

> 4n boundaries you should send it back as 'not fit for purpose'.

    I'm afraid we can't. :-)
    However, my colleague has suggested a scheme minimizing the copying:
only up to 3 first bytes need to be copied to the driver's internal buffers, 
the rest can be sent from an skb itself. That would require substantial 
changes to the driver though...

> 	David

WBR, Sergei
