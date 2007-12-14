From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [patch 02/10] forcedeth: power down phy when interface is down
Date: Thu, 13 Dec 2007 16:51:22 -0800
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F5203FF45C4@orsmsx418.amr.corp.intel.com>
References: <200712140002.lBE02qo1025508@imap1.linux-foundation.org><F72FA20C31DD4F4C997B91C5B3690A091A990D@hqemmail07.nvidia.com> <20071213163046.c2e9d340.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <jeff@garzik.org>, <netdev@vger.kernel.org>, <eswierk@arastra.com>
To: "Andrew Morton" <akpm@linux-foundation.org>,
	"Ayaz Abdulla" <AAbdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:28976 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761400AbXLNA5S convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 19:57:18 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20071213163046.c2e9d340.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> On Thu, 13 Dec 2007 16:11:55 -0800
> "Ayaz Abdulla" <AAbdulla@nvidia.com> wrote:
> 
>> I would not include this patch until further testing is performed.
>> NVIDIA MCP chips use 3rd party PHY vendors. By powering down the
>> phy, it could have adverse affects on certain phys.
>> 
>> Ayaz
>> 
>> 
>> -----Original Message-----
>> From: akpm@linux-foundation.org [mailto:akpm@linux-foundation.org]
>> Sent: Thursday, December 13, 2007 4:03 PM
>> To: jeff@garzik.org
>> Cc: netdev@vger.kernel.org; akpm@linux-foundation.org;
>> eswierk@arastra.com; Ayaz Abdulla
>> Subject: [patch 02/10] forcedeth: power down phy when interface is
>> down 
>> 
>> 
>> From: "Ed Swierk" <eswierk@arastra.com>
>> 
>> Bring the physical link down when the interface is down by placing
>> the PHY in power-down state, unless WOL is enabled.  This mirrors
>> the behavior of other drivers including e1000 and tg3.
> 
> Does this patch actually fix any observeable problem?

as a side note this one feature has caused more bugs than almost any
feature I can think of in e1000.  If Linux had a decent power manager
that handled PCI device D-states (D0/D3) then most hardware that is able
to be certified in M$ OSes would already implement power savings just by
going to D3 when it was not being used.  In e1000's case all the "power
down phy" logic would become useless because the hardware already has a
huge dependency tree that it walks when going to D3 to decide if it can
power down the link, or go to a lower power link (like 100Mb or 10Mb)

/rant
Jesse

