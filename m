From: Brent Cook <bcook@breakingpoint.com>
Subject: Re: Occasional link flap on Intel 82599 on boot in XAUI mode
Date: Mon, 14 Mar 2011 14:21:56 -0500
Message-ID: <201103141421.56212.bcook@breakingpoint.com>
References: <201102251011.42400.bcook@breakingpoint.com> <29F4ED941D916B48B88B4D2A4F3D1B9C01D30140EF@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.breakingpoint.com ([65.36.7.12]:28654 "EHLO
	EXCHANGE.securitytestsystems.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753022Ab1CNTWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 15:22:54 -0400
In-Reply-To: <29F4ED941D916B48B88B4D2A4F3D1B9C01D30140EF@orsmsx509.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 25 February 2011 12:11:11 Skidmore, Donald C wrote:
> >-----Original Message-----
> >From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> >On Behalf Of Brent Cook
> >Sent: Friday, February 25, 2011 8:12 AM
> >To: netdev@vger.kernel.org
> >Subject: Occasional link flap on Intel 82599 on boot in XAUI mode
> >
> >We have a custom system with dual 82599's in XAUI mode. One has its pair
> >of ports connected to a 10G switch, the other has its pair of ports
> >connected to an FPGA.
> >
> >Occasionally, on any of the interfaces, we will see the links flapping
> >up and down when the system initially boots. This happens maybe one in
> >20 boots.
> >
> >Feb 23 14:58:10 mfg kernel: [  594.254977] ixgbe: eth1 NIC Link is Down
> >Feb 23 14:58:12 mfg kernel: [  596.230039] ixgbe: eth1 NIC Link is Up 10
> >Gbps, Flow Control: RX/TX
> >Feb 23 14:58:12 mfg kernel: [  596.256537] ixgbe: eth1 NIC Link is Down
> >Feb 23 14:58:16 mfg kernel: [  600.228096] ixgbe: eth1 NIC Link is Up 10
> >Gbps, Flow Control: RX/TX
> >Feb 23 14:58:16 mfg kernel: [  600.240135] ixgbe: eth1 NIC Link is Down
> >Feb 23 14:58:18 mfg kernel: [  602.227047] ixgbe: eth1 NIC Link is Up 10
> >Gbps, Flow Control: RX/TX
> >
> >Simply forcing a down/up on the interface seems to correct the problem:
> >
> >ip link set eth1 down
> >ip link set eth1 up
> >
> >Is anyone else using XAUI mode and has seen this? Here is the kernel
> >information that we are using currently:
> >
> 
> By any chance have you tried it with a newer driver?  Latest Source Forge is 3.2.9.
> 
> Also do you only see this link flap on boot, can you recreate the flap by unload and loading the ixgbe module?
> 

We updated to the latest source forge driver and had the same behavior. Reloading the driver does not reproduce the issue.

It seems to be related to the remote XAUI peer coming out of reset after the 82599. The FPGAs on one pair of links are loaded in software at boot time, and the switch reset is also delayed slightly compared to the 82599.  We fixed the issue by doing 'ethtool -r' once for each link at boot time.

Thanks
 - Brent
