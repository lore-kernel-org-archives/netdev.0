From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Two Dual Core processors and NICS (not handling interrupts on
 one	CPU/assigning a Two Dual Core processors and NICS (not handling	interrupts
 on one CPU / assigning a CPU to a NIC)
Date: Tue, 16 Jan 2007 09:34:34 -0800
Message-ID: <45AD0CAA.7060601@hp.com>
References: <dac45060701150115y5308f7b5ka44f2ea4ae304d4b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:45398 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751948AbXAPReg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jan 2007 12:34:36 -0500
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
> ...
> Permanent HW addr: ....
> 
> (And the Permanent HW addr is diffenet in these two entries).
> 
> I send a large amount of packets to this machine (more than 20,000 in
> a second).

Well, 20K a second is large in some contexts, but not in others :)
> 
> cat /proc/interrupts shops something like this:
>                 CPU0       CPU1         CPU2         CPU3
> 50:    3359337          0          0          0         PCI-MSI  eth0
> 58:         49    3396136          0          0         PCI-MSI  eth1
> 
> CPU0 and CPU1 are of the first CPU as far as I understand ; so this
> means as far as I understand that the second CPU (which has CPU3 and
> CPU4) does not handle interrupts of the arrived packets; Can I
> somehow change it so the second
> CPU will also handle network interrupts of receiving packets on the
> nic ?

Actually, those could be different chips - it depends on the CPUs I 
think, and I suppose the BIOS/OS.  On a Woodcrest system with which I've 
been playing, CPUs 0 and 2 appear to be on the same die, then 1 and 
three.   I ass-u-me-d the numbering was that way to get maximum 
processor cache when saying "numcpu=N" for something less than the 
number of cores in the system.

NUMA considerations might come into play if this is Opteron (well, any 
NUMA system really - larger IA64's, certain SPARC and Power systems 
etc...).  In broad handwaving terms, one is better-off with the NICs 
interrupts being handled by the topologically closest CPU.  (Not that 
some irqbalancer programs recognize that just yet :)

Now, if both CPU0 and CPU1 are saturated it might make sense to put some 
interrupts on 2 and/or 3.  One of those fun "it depends" situations.

rick jones
