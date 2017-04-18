From: Daniel Walker <danielwa@cisco.com>
Subject: Re: Marvell phy errata origins?
Date: Tue, 18 Apr 2017 07:18:03 -0700
Message-ID: <3c16d944-9874-d016-e3f1-68055a22c173@cisco.com>
References: <59691a35-a89c-f9ca-c7b0-73134a737f4c@cisco.com>
 <20170418140450.GB13724@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Andy Fleming <afleming@freescale.com>,
        Harini Katakam <harini.katakam@xilinx.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        HEMANT RAMDASI <hramdasi@cisco.com>,
        "Julius Hemanth Pitti -X (jpitti - MONTA VISTA SOFTWARE INC at Cisco)"
        <jpitti@cisco.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgl-iport-2.cisco.com ([72.163.197.26]:3604 "EHLO
        bgl-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750758AbdDRO2I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 10:28:08 -0400
In-Reply-To: <20170418140450.GB13724@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/18/2017 07:04 AM, Andrew Lunn wrote:
> On Tue, Apr 18, 2017 at 06:16:33AM -0700, Daniel Walker wrote:
>> Hi,
>>
>> Cisco is using a Marvell 88E1112 phy. It seems to be fairly similar
>> to the 88E1111 which Harini added a fix for.
> Hi Daniel
>
> If you look at Marvell reference drive, DSDT, they are actually quite
> different. Different virtual cable tester, different downshift
> configuration, different packet generator, different loopback. I would
> say they are different generations of PHY.

Ok .

>
>> In Harini's commit
>> message for ,
>>
>> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/drivers/net/phy/marvell.c?id=3ec0a0f10ceb
>>
>> "This function has a sequence accessing Page 5 and Register 31, both
>> of which are not defined or reserved for this PHY"
>>
>> For the 88E1112 we see that these are "Factory Test Modes" which the
>> contents of are not documented. They aren't really "not defied", and
>> aren't really "reserved" .. Marvell support claims they don't
>> support these drivers, and Freescale seems to be adding these
>> drivers, and the line we are looking at.
>>
>> We had some issues with our PHY which were corrected with the same
>> patch Harini used but modified for the M88E1112. We're trying to get
>> to the bottom of where this code came from and what it was suppose
>> to be doing.
> I tried to find this errata fix in the Marvell reference code. And
> failed to find it. But it is "Vendor Crap" code, hard to find anything
> in it.
>
> My guess is, this errata just applies to one model of PHY, maybe even
> one revision of one model of a PHY. The hard bit is figuring out what
> actually needs it. Do you have access to Marvell datasheets?

Prior to Andy's commit this code was duplicated in at least a couple of 
the ethernet drivers from Freescale. I think all Andy did was combine 
them all.

I think the data sheet is here for the 1112,

http://www.dexsilicium.com/Marvell_88E1112.pdf

This is what I've been using. My contact with Marvell for support is 
minimal. Andy's email at Freescale bounced , so maybe someone else form 
Freescale could comment. There must have been something very strange 
getting fixed due to using unnamed hex values in the code.

Daniel
