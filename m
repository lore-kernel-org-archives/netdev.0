From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: DSA vs. SWTICHDEV ?
Date: Thu, 1 Dec 2016 11:50:12 -0500
Message-ID: <584054C4.1010809@ti.com>
References: <1480495831.3563.135.camel@infinera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
To: Joakim Tjernlund <Joakim.Tjernlund@infinera.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Roger Quadros <rogerq@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lelnx194.ext.ti.com ([198.47.27.80]:50405 "EHLO
        lelnx194.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751147AbcLAQuJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 11:50:09 -0500
In-Reply-To: <1480495831.3563.135.camel@infinera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/30/2016 03:50 AM, Joakim Tjernlund wrote:
> I am trying to wrap my head around these two "devices" and have a hard time telling them apart.
> We are looking att adding a faily large switch(over PCIe) to our board and from what I can tell
> switchdev is the new way to do it but DSA is still there. Is it possible to just list
> how they differ?
> 
> What can switchdev do that DSA cannot?
> 
> What can DSA do that switchdev cannot?
> 
> 
> Can one enable switchdev and dsa for the same switch device?
> 
>  Jocke 
> 

DSA/Switchdev experts,

Nice to see this discussion as I am trying to evaluat what model
works best for our hardware. From my evaluation so far, DSA can be
used even though there is no tag protocol used between the Host and
Switch. In our hardware, the Host and Switch are part of the SoC.
The Host interface is a shared memory with queues implemented at
hardware. The Phy is attached to the mii ports externally on the board.
Also this hardware is programmable through firmware. More details 
can be seen at http://processors.wiki.ti.com/index.php/PRU-ICSS
PRU can run a firmware to configure the hardware in one of the following:-

1. EMAC mode where it appears as two Ethernet ports
2. Switch mode where it implements a simple Ethernet switch. Currently
   it doesn't have address learning capability, but in future it
   can.
3. Switch with HSR/PRP offload where it provides HSR/PRP protocol
   support and cut through switch.

So a device need to function in one of the modes. A a regular Ethernet
driver that provides two network devices, one per port, and switchdev
for each physical port (in switch mode) will look ideal in this case.
This will allow attaching the associated interfaces to a bridge (where
a L2 offload is possible in the future). This also helps to attach the
interfaces to an HSR device at the top layer like bridge to support
HSR/PRP protocol with offload possible to the PRU Switch.

Using a DSA for this appears to be adding more complexity to the driver
model and may not be ideal. What do you think? 

-- 
Murali Karicheri
Linux Kernel, Keystone
