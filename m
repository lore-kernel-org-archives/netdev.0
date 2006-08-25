From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH -rt DO NOT APPLY] Fix for tg3 networking lockup
Date: Fri, 25 Aug 2006 15:55:33 -0700
Message-ID: <1156546533.5021.10.camel@rh4>
References: <20060805202603.GA9740@thunk.org>
 <1551EAE59135BE47B544934E30FC4FC093FA21@NT-IRVA-0751.brcm.ad.broadcom.com>
 <loom.20060825T235849-675@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4366 "EHLO MMS3.broadcom.com")
	by vger.kernel.org with ESMTP id S964782AbWHYW4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2006 18:56:22 -0400
To: "Marc Bevand" <m.bevand@gmail.com>
In-Reply-To: <loom.20060825T235849-675@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-08-25 at 22:33 +0000, Marc Bevand wrote:

> Still, it would be great if ASF could be disabled, because I have
> noticed that when ASF is enabled, the tg3 driver automatically disables
> TSO (TCP Segmentation Offloading). Here is a dmesg output from a server
> where I am seeing that behavior:
> 
>   eth0: Tigon3 [partno(BCM95704A6) rev 2100 PHY(5704)] (PCIX:133MHz:64-bit) \
>     10/100/1000BaseT Ethernet 00:30:48:59:c4:94
>   eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1] Split[0] WireSpeed[1] TSOcap[0]
>   [...]
>   eth1: Tigon3 [partno(BCM95704A6) rev 2100 PHY(5704)] (PCIX:133MHz:64-bit) \
>     10/100/1000BaseT Ethernet 00:30:48:59:c4:95
>   eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] Split[0] WireSpeed[1] TSOcap[1]
> 
> Both interfaces are fundamentally TSO-capable, but since ASF is enabled
> on eth0, tg3 disables TSO on this interface. Of course at this point it
> is not even possible to use ethtool to re-enable it because the driver
> considers eth0 as not TSO-capable at all.
> 

The reason is that TSO on 5704 and older chips is done by firmware.  ASF
is also implemented by firmware.  If ASF is enabled, there is no room to
do TSO and ASF at the same time.

Firmware-based TSO is actually slower than no TSO.  The only benefit is
a little better CPU utilization.

On the newer chips, TSO is done by hardware which solves both the ASF
and throughput problems.

