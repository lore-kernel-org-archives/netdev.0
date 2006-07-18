From: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Subject: Re: Simultanious transmits seems to cause hang on pcnet32
Date: Tue, 18 Jul 2006 14:45:12 -0400
Message-ID: <20060718184512.GU13639@csclub.uwaterloo.ca>
References: <20060718152016.GA13642@csclub.uwaterloo.ca> <20060718175747.GA22735@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:47576 "EHLO
	caffeine.csclub.uwaterloo.ca") by vger.kernel.org with ESMTP
	id S932352AbWGRSpN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jul 2006 14:45:13 -0400
To: Don Fry <brazilnut@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <20060718175747.GA22735@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 18, 2006 at 10:57:47AM -0700, Don Fry wrote:
> I don't know what a 'smartbits test system' is or how it works.  Could
> you please briefly explain what it is and does?

It is a network test system built by spirent (www.spirentcom.com).

It is mainly a layer 2 test system (you configure what you want it
ethernet packet to look like, what rate you want them sent at, and what
fields to change and by how much on each packet sent out).  We have it
configured to generate packets from 192.168.1.2 to 192.168.3.2 (and vice
versa), with the ip of the router with the pcnet32 chips in it, set as
the gateway.  The packets are simply an ethernet packet with the IPv4
header with the source and destination IP filled in, along with the
other required fields and the checksum, and then the data part of the
packet filled with 0s in this case.

> Is the rdl8139 on the same PCI bus?

The 8139 is on the primary PCI bus, the 972s are behind the pci bridge.
The 8139 driver is normally not even loaded.

> Is there a version of the pcnet32 driver that does work?  Is this a
> stock driver or do you have modifications made as well?

I haven't found one that works yet.  The only changes I have made are to
initialize the PHY and set the MAC address, since we don't have an eeprom
connected to the 972s.  I was thinking of going and trying with 2.4.27
or something around there, to see if an older driver behaves differently.

> The ltint or TxDone interrupt deferral code was removed in May 2004,
> 2.6.7 timeframe.  Every transmit packet causes an interrupt, rather than
> just occasionally.

Hmm, the way I read the code, it looked like setting the status to 8300
made no packet generate the interrupt, and setting it to 9300 made a
packet generate an interrupt.  I guess I read it backwards.  That
wouldn't surprise me. :)

> Does reducing the ring size make any difference?  Or tx large/rx small,
> or vice-versa?

I don't know.  I can try that.

> Is there any way to see what is happening on the PCI bus where the
> pcnet32 devices are connected?  Or see what is happening on the master
> side of the pci-to-pci bridge?  Do the chips share any interrupt lines
> or do they all have dedicated irq's?

We have two interrupts for the PCI bus, irq10 and 11.  eth1 and 3 share
one, and eth2 and 4 share the other.

> Is this an SMP or UP system?

Single amd geode SCx200 266MHz.

I have also considered building with PREEMPT off, to see if that makes a
difference, not that there are really any user space processes doing
anything on the system.

--
Len Sorensen
