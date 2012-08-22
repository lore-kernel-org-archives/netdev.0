From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH] netdev/phy: add MDIO bus multiplexer driven by a memory-mapped
 FPGA
Date: Wed, 22 Aug 2012 15:52:32 -0700
Message-ID: <503562B0.3010005@caviumnetworks.com>
References: <1345671954-6398-1-git-send-email-timur@freescale.com> <50355C05.6000407@gmail.com> <50355F6D.4070002@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Daney <ddaney.cavm@gmail.com>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	Andy Fleming <afleming@freescale.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<david.daney@cavium.com>
To: Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe004.messaging.microsoft.com ([216.32.180.14]:22848
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754501Ab2HVWwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 18:52:40 -0400
In-Reply-To: <50355F6D.4070002@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/22/2012 03:38 PM, Timur Tabi wrote:
> David Daney wrote:
>
>> I wonder if *fpga is really a good name for this.  It is a general
>> purpose multiplexer with a memory mapped control register.  I would call
>> it something like mdio-mux-mmioreg.
>
> At one point, I thought of using mdio-mux-bitbang, but -mmioreg is better.
>   Thanks.
>
>>> +- mdio-mux-device : phandle, points to the FPGA (or similar) node.  This
>>> +	must be a memory-mapped device with 8-bit registers.
>>
>> You shouldn't need this.  Just make the multiplexer a child of FPGA node
>> to indicate where it lives.
>
> The problem is that we don't normally consider the FPGA node to be a bus,
> so its child nodes won't get probed.  That's why I have this:
>

That would seem to be a mistake/error.

You should be able to arrive at any directly addressable register by 
walking down the tree to the children and applying any "ranges" 
properties at each node.  The OF infrastructure will take care of 
resolving all the addresses and you get rid of much of the code you 
added to duplicate its function.
