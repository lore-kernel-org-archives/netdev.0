From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] forcedeth: Addition of new device id (resend without
 pci_ids.h)
Date: Wed, 03 Jun 2009 14:59:02 -0700 (PDT)
Message-ID: <20090603.145902.185480919.davem@davemloft.net>
References: <4A269F6C.7030300@nvidia.com>
	<20090603.144456.01215273.davem@davemloft.net>
	<4A26A3C5.5030607@nvidia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manfred@colorfullife.com, akpm@osdl.org, netdev@vger.kernel.org
To: aabdulla@nvidia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33298
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751783AbZFCV7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 17:59:01 -0400
In-Reply-To: <4A26A3C5.5030607@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ayaz Abdulla <aabdulla@nvidia.com>
Date: Wed, 03 Jun 2009 12:24:37 -0400

> 
> 
> David Miller wrote:
>> From: Ayaz Abdulla <aabdulla@nvidia.com>
>> Date: Wed, 03 Jun 2009 12:06:04 -0400
>> 
>>>Add support for new ethernet device in the MCP89 chipset.
>>>
>>>Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>
>> Just use the constant directly, please :-)
> 
> But there is place in the patch that refers to device id so it makes
> more sense to have a macro. i.e
> 
> +       if (np->device_id != PCI_DEVICE_ID_NVIDIA_NVENET_40)
> 
> other places in the code also refer to device ids for certain
> workarounds. i.e.
> 
> 		if ((id->device == PCI_DEVICE_ID_NVIDIA_NVENET_12 ||
> 		     id->device == PCI_DEVICE_ID_NVIDIA_NVENET_13) &&

And you can add the define when that is necessary.

Otherwise, it's being used in exactly one location, the ID table.
And for that purpose it's superfluous.

You could also change the driver to use a bitmask of HW workaround
cases, that gets set very early in the probe.  And the HW
workarounds are keyed on those bit masks (one test) compared
to the direct ID checks (potentially multiple compares).

It would be both cleaner and more efficient.  And you could still
use the direct constants without any real loss of clarity.
