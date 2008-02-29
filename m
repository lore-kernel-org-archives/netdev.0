From: Mark Seger <Mark.Seger@hp.com>
Subject: Collectl now support monitoring Interrupts by CPU
Date: Fri, 29 Feb 2008 08:18:18 -0500
Message-ID: <47C8061A.6080009@hp.com>
References: <477FDAA8.2030001@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: util-linux-ng@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:26179 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753271AbYB2NSR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 08:18:17 -0500
In-Reply-To: <477FDAA8.2030001@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In keeping with the spirit of adding new useful features when they help 
solve real world problems, I've added this ability to collectl as a 
direct result of a problem we were recently having when doing some 
network performance testing.  It turned out all the interrupts were 
being processed by cpu0 (this was on an 8-core system) but all collectl 
told us was the aggregate number!  Once we moved to a NIC/driver that 
supported multiple queues that could distribute interrupts to multiple 
CPUs it only made sense to enhance collectl to let us verify that this 
was indeed happening - I personally find examining /proc/interrupts for 
changes more trouble than it's worth.

In any event, the following is an example of how collectl can present 
this data, first summarized by CPU:

#Time     Cpu0 Cpu1 Cpu2 Cpu3 Cpu4 Cpu5 Cpu6 Cpu7
12:49:55  4828  16K 1000  16K   18  16K  16K    0
12:49:56  4804  16K 1000  16K    0  16K  16K    0
12:49:57  4811  16K 1000  16K   18  16K  16K    0
12:49:58  4789  16K 1000  16K    0  17K  16K   44

and here by the type of the interrupt itself:

# INTERRUPT DETAILS
#          Int    Cpu0   Cpu1   Cpu2   Cpu3   Cpu4   Cpu5   Cpu6   Cpu7 
  Type            Device(s)
12:48:50   082       0      0      0   7731      0      0      0      
0   PCI-MSI-X       eth2 (queue 0)
12:48:50   098       0      0      0      0   2037      0      0      
0   PCI-MSI-X       eth2 (queue 2)
12:48:50   122       0      0   2240      0      0      0      0      
0   PCI-MSI-X       eth2 (queue 5)
12:48:50   138       0   7084      0      0      0      0      0      
0   PCI-MSI-X       eth2 (queue 7)
12:48:50   154       0      0      0      0      0   7723      0      
0   PCI-MSI-X       eth3 (queue 0)
12:48:50   162    9082      0      0      0      0      0      0      
0   PCI-MSI-X       eth3 (queue 1)
12:48:50   178       0      0      0      0      0      0   8253      
0   PCI-MSI-X       eth3 (queue 3)
12:48:50   210       0      0      0      0      0      0      0   
6417   PCI-MSI-X       eth3 (queue 7)
12:48:50   218       1      0      0      0      0      0      0      
0   PCI-MSI         eth0

You can also look at all CPU loads and interrupts together like this:

# SINGLE CPU STATISTICS
#            CPU  USER NICE  SYS WAIT IRQ  SOFT STEAL IDLE INTRPT
07:09:28       0     0    0    0    0    0    0     0  100     16
07:09:28       1     0    0    0    0    0    0     0  100      0
07:09:28       2     0    0    0    0    0    0     0  100    999
07:09:28       3     0    0    0    0    0    0     0  100     16

For those not familiar with collectl, you can collect virtually 
everything all the existing linux 'stat' utilitie provide plus a lot 
more such as processes (including I/O stats), Infininband, Quadrics, 
Slab, Lustre and more.  Plus a lot more feature too numerous to list but 
there's a pretty good summary here - 
http://collectl.sourceforge.net/Features.html

But don't take my word for it, check out the website at 
http://collectl.sourceforge.net/ where you can see a pretty good set of 
examples in the documentation and even follow the tutorial.

-mark
