From: Tabi Timur-B04825 <B04825@freescale.com>
Subject: Re: [PATCH] netdev/phy: add MDIO bus multiplexer driven by a
 memory-mapped FPGA
Date: Thu, 23 Aug 2012 00:06:32 +0000
Message-ID: <6AE080B68D46FC4BA2D2769E68D765B7059B75BB@039-SN2MPN1-022.039d.mgd.msft.net>
References: <1345671954-6398-1-git-send-email-timur@freescale.com>
 <50355C05.6000407@gmail.com> <50355F6D.4070002@freescale.com>
 <503562B0.3010005@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Tabi Timur-B04825 <B04825@freescale.com>,
	David Daney <ddaney.cavm@gmail.com>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	Fleming Andy-AFLEMING <afleming@freescale.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"david.daney@cavium.com" <david.daney@cavium.com>
To: David Daney <ddaney@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe004.messaging.microsoft.com ([213.199.154.207]:25611
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756749Ab2HWAGi convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2012 20:06:38 -0400
In-Reply-To: <503562B0.3010005@caviumnetworks.com>
Content-Language: en-US
Content-ID: <4CEFD8E728E0C84FB2C7068516BE9A78@mgd.freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Daney wrote:
>>
>> The problem is that we don't normally consider the FPGA node to be a bus,
>> so its child nodes won't get probed.  That's why I have this:
>>
>
> That would seem to be a mistake/error.

Maybe I'm not explaining myself well.  A node that has children will not 
automatically probe the children unless something in arch code registers 
the parent as a bus.  If you look in corenet_ds.c, you'll see what we do 
with array of_device_ids[].  We list all of the nodes that are buses.  The 
mdio-mux root-level nodes that I have today won't work unless I add 
.compatible = "mdio-mux" to of_device_ids[].

>
> You should be able to arrive at any directly addressable register by
> walking down the tree to the children and applying any "ranges" properties
> at each node.  The OF infrastructure will take care of resolving all the
> addresses and you get rid of much of the code you added to duplicate its
> function.

That only works for buses that are already registered.  I think if I add 
"simple-bus" to the compatible of the FPGA node, it will work.  I'll try 
that tomorrow.

-- 
Timur Tabi
Linux kernel developer at Freescale
