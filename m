From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: Re: [PATCH] Force speed and duplex mode setting if link down
Date: Tue, 3 Jun 2014 10:12:11 -0700
Message-ID: <285C9B27-0A11-4532-90B6-AF7595057F51@cumulusnetworks.com>
References: <1401750420-6668-1-git-send-email-stannous@cumulusnetworks.com> <CAGVrzcZMkjFHjE3O80nPe4hmRUgfjWsoY0_g6dNPHKvBRKpOmg@mail.gmail.com> <1075088676.3395812.1401760022657.JavaMail.zimbra@cumulusnetworks.com> <063D6719AE5E284EB5DD2968C1650D6D17256451@AcuExch.aculab.com>
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Sam Tannous <stannous@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:46059 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933133AbaFCRMb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 13:12:31 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D17256451@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jun 3, 2014, at 2:13 AM, David Laight <David.Laight@ACULAB.COM> wrote:

> From: Of Sam Tannous
>> 
>> I probably didn't make this clear enough in the description.
>> I'm not describing a use case.   I'm simply changing the
>> speed on two interfaces that are directly connected.
>> I don't have autoneg on at all.
>> 
>> 1. I start with a working link where the speed is
>>   10G and duplex is full on both sides.
>> 
>> 2. I change the speed on one side to 1G with
>> 
>>      ethtool -s speed 1000
>> 
>>   and the command appears to work (at least there is no error message).
>>   Once I issue this command, the link is no longer usable
>>   since the speed changed on one side but not the other.  Autoneg
>>   is disabled (by default).
> 
> You really want to leave autoneg enabled and just limit the advertised
> speeds.

This patch is about the forced speed/duplex case, which is one way to set settings.  Autoneg is another.

> I suspect there are plenty of ways ethtool can be used to make
> non-working interfaces, some of them might be needed be developers
> or in unusual circumstances.
> So I don't think ethtool should be policing this specific condition.

Why not?  The patch enforces the specific condition when input from the user is ambiguous.  When link is down, and user is forcing speed only, there is not enough information to know duplex, and ethtool app is defaulting to HDX, which is usually the wrong choice for most interfaces.  The patch forces the user to be explicit on speed and duplex in this ambiguous case.

> Maybe the driver should just use FDX when HDX is invalid for the
> speed.

No, the driver should fail an attempt to set HDX when not supported.

-scott
