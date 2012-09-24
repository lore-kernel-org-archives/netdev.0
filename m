From: leroy christophe <christophe.leroy@c-s.fr>
Subject: Re: [PATCH v4] lxt PHY: Support for the buggy LXT973 rev A2
Date: Mon, 24 Sep 2012 16:40:07 +0200
Message-ID: <506070C7.9020507@c-s.fr>
References: <201209241400.q8OE0w38011790@localhost.localdomain> <AE90C24D6B3A694183C094C60CF0A2F6026B7004@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David S Miller <davem@davemloft.net>,
	Richard Cochran <richardcochran@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7004@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Le 24/09/2012 16:13, David Laight a =E9crit :
>> This patch adds proper handling of the buggy revision A2 of LXT973 p=
hy, adding
>> precautions linked to ERRATA Item 4:
>>
>> Revision A2 of LXT973 chip randomly returns the contents of the prev=
ious even
>> register when you read a odd register regularly
> Does reading the PHY registers involve bit-banging an MII interface?
> If so this code is likely to stall the system for significant
> periods (ready phy registers at all can be a problem).
>
> I know some ethernet mac have hardware blocks for reading MII
> and even polling one MII register for changes.
>
> Maybe some of this code ought to be using async software
> bit-bang - especially when just polling for link status change.
> I'm sure it ought to be possible to do one bit-bang action
> per clock tick instead of spinning for the required delays.
>
> 	David
>
Not sure I understand what you mean. We have been using this code=20
without any problem for about 2 years on our Hardware.
It does almost same as genphy_read_status() except that it also reads=20
the BMCR register (which is the register preceeding the BMSR) in order=20
to detect the unlikely happening of the bug reported by the ERRATA. In=20
case it happens (which is really seldom), it does a re-read.
We are not spinning on any delays here.

Christophe
