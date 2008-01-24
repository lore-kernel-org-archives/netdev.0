From: Timur Tabi <timur@freescale.com>
Subject: Re: [PATCH UCC TDM 1/3 Updated] Platform changes for UCC TDM driver
 for MPC8323eRDB. Also includes related QE changes and dts entries.
Date: Thu, 24 Jan 2008 10:33:47 -0600
Message-ID: <4798BDEB.2010501@freescale.com>
References: <Pine.LNX.4.64.0801241553270.4984@linux121> <20080124154804.GA22178@localhost.localdomain> <4798B4F3.2010101@freescale.com> <20080124162345.GA27359@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Poonam_Aggrwal-b10812 <b10812@freescale.com>,
	kumar.gala@freescale.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rubini@vision.unipv.it, linuxppc-dev@ozlabs.org,
	michael.barkowski@freescale.com, rich.cutler@freescale.com,
	ashish.kalra@freescale.com
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:60222 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752088AbYAXQsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 11:48:20 -0500
In-Reply-To: <20080124162345.GA27359@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anton Vorontsov wrote:

> Are you saying that TDM is sharing same pins with the other QE device,
> and we can choose to use/not use some device depending on which driver
> is loaded?

No.  I'd have to closely examine the DTS, but I don't think that UCC devices 
share pins at all.  But that isn't my point.

> In that particular case UCC configuration is static, for every UCC.
> So, we can set up all pins in the firmware/board file.

Yes, but deciding what the UCC does might not be static.  At what point do we 
declare, "UCC5 is for eth0 and eth0 only"?

The advantage of putting the pin configurations in the device tree is that they 
now become configurable.  I can envision a scenario where UCC5 could be either 
an Ethernet or a UART, depending on the setting of some jumpers on the board. 
That's what the QE was designed for: any UCC can do any task, and you can even 
have a UCC change its purpose while the system is running.  So I don't want the 
pin configurations hard-coded into the kernel.  Having them in the device tree 
gives me some flexibility.

For instance, I have a plan (that I keep postponing) to introduce a new feature 
in U-Boot where U-Boot can determine the settings of some board jumpers and 
modify the device tree accordingly.  The instructions on how to modify the 
device tree would be embedded in the tree itself.  I can't support this feature 
if the kernel calls par_io_config_pin() regardless of what's in the device tree.

-- 
Timur Tabi
Linux kernel developer at Freescale
