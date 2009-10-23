From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: VLAN and ARP failure on tg3 drivers
Date: Fri, 23 Oct 2009 14:35:32 -0700
Message-ID: <20091023213532.GA9866@xw6200.broadcom.net>
References: <93821.71108.qm@web32607.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Gertjan Hofman" <gertjan_hofman@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1297 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751543AbZJWVfi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2009 17:35:38 -0400
In-Reply-To: <93821.71108.qm@web32607.mail.mud.yahoo.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 22, 2009 at 09:52:42PM -0700, Gertjan Hofman wrote:
> Dear Kernel developers,
> 
> A couple of weeks ago we tried to migrate from a 2.6.24? kernel to a 2.6.29 kernel and noticed our VLAN application no longer works.? The problem is easy to replicate:
> 
> 1. connect 2 PC's with a cross-over cable
> 2. set up a fixed IP address to both PC's? (say 192.168.0.[1,2])
> 3. create a vlan:? vconfig? add eth0 0.
> 4. set IP addresses on the VLAN devices? (say 192.168.1.[1,2])
> 5. try ping one machine from the other.
> 
> I tried to dig into the problem by using un-patched kernel.org kernels with Ubuntu .config files.? Kernels up to 2.6.26 work fine, kernels after and including 2.6.27 fail. The problem is that ARP messages are being dropped. If the ARP table is updated by hand on each machine, the communication across the VLAN works fine.
> 
> At first I thought the kernel VLAN code was the problem (we had an earlier issue with a regression in 2.6.24) but it looks like the problem is actually with the tg3 driver.? Our system uses Broadcom ethernet chips. I tried the same experiments with combination of boards that have Broadcom and none-Broadcom and the only time I see it fail is with the tg3? driver loaded.
> 
> Snooping with WireShark shows that a ARP request from the non-Broadcom machine is seen and even answered, but never appears back on the network. If the Broadcom machine orginates the ARP message, it never arrives at the destination. I tried lowering the size of the MTU to 1492 as well as giving each VLAN device a different MAC. No deal.
> 
> I tried to look at tg3 patch changes from 2.6.26 to 2.6.27 but I am not familiar enough with the Git system to extract the appropiate changes.? I am a bit surprised that I am not seeing any references to this on the web, the combination of >2.6.27 kernels, Broadcom and VLAN cant be that uncommon.
> 
> I would be happy to provide more information and to try tests if any one can suggest them.
> 
> Sincerely,
> 
> Gertjan

I don't see any reason why your setup should fail, but it doesn't hurt
to gather more info about the problem.

What device are you experiencing this problem with?  Is management
firmware enabled?  (`ethtool -i ethx`)

