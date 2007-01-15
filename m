From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: Two Dual Core processors and NICS (not handling interrupts on
 one CPU/assigning a Two Dual Core processors and NICS (not handling interrupts
 on one CPU / assigning a CPU to a NIC)
Date: Mon, 15 Jan 2007 08:52:05 -0800
Message-ID: <45ABB135.1010202@intel.com>
References: <dac45060701150115y5308f7b5ka44f2ea4ae304d4b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:33908 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751018AbXAOQwG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jan 2007 11:52:06 -0500
To: Mark Ryden <markryde@gmail.com>
In-Reply-To: <dac45060701150115y5308f7b5ka44f2ea4ae304d4b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Ryden wrote:
> Hello,
> 
> 
> I have a machine with 2 dual core CPUs. This machine runs Fedora Core 6.
> I have two Intel e1000 GigaBit network cards on this machine; I use 
> bonding so
> that the machine assigns the same IP address to both NICs ;
> It seems to me that bonding is configured OK, bacuse when running:
> "cat /proc/net/bonding/bond0"
> I get:
> 
> Ethernet Channel Bonding Driver: v3.0.3 (March 23, 2006)
> 
> Bonding Mode: load balancing (round-robin)
> MII Status: up
> MII Polling Interval (ms): 100
> Up Delay (ms): 0
> Down Delay (ms): 0
> 
> Slave Interface: eth0
> MII Status: up
> Link Failure Count: 1
> Permanent HW addr: .....
> 
> Slave Interface: eth1
> MII Status: up
> Link Failure Count: 1
> Permanent HW addr: ....
> 
> (And the Permanent HW addr is diffenet in these two entries).
> 
> I send a large amount of packets to this machine (more than 20,000 in
> a second).
> 
> cat /proc/interrupts shops something like this:
>                 CPU0       CPU1         CPU2         CPU3
> 50:    3359337          0          0          0         PCI-MSI  eth0
> 58:         49    3396136          0          0         PCI-MSI  eth1
> 
> CPU0 and CPU1 are of the first CPU as far as I understand ; so
> this means as far as I understand that the second CPU (which has CPU3
> and CPU4) does not handle
> interrupts of the arrived packets; Can I somehow change it so the second
> CPU will also handle network interrupts of receiving packets on the nic ?
> 
> Can I assign one CPU to  eth0 and the second CPU to eth1  ?

you will most likely have better performance from the shared cache on the core 2 duo by 
keeping it the way that it is right now - packets that need to transverse the bridge now 
make the cpus happy because after receive the sending NIC already has the data in it's 
cache. Moving one of the NICs over to cpu2/cpu3 would cause a cascade of cache misses 
for every packet that passes across the two nics in the bridge.

Cheers,

Auke
