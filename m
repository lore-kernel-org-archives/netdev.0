From: Daniel Walker <danielwa@cisco.com>
Subject: Re: Marvell phy errata origins?
Date: Tue, 9 May 2017 06:58:58 -0700
Message-ID: <ffd12ac5-7501-0310-182f-1735c2da8165@cisco.com>
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
Received: from alln-iport-6.cisco.com ([173.37.142.93]:62344 "EHLO
        alln-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751210AbdEIN7B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 09:59:01 -0400
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

According to Marvell this was errata for 88M1101 , and should not be 
applied to any other phy .. So we should be removing these lines and 
make a special aneg for 88M1101 then restore everything that doesn't 
need this back to the generic aneg,

Daniel
