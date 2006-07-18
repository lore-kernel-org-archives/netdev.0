From: Don Fry <brazilnut@us.ibm.com>
Subject: Re: Simultanious transmits seems to cause hang on pcnet32
Date: Tue, 18 Jul 2006 10:57:47 -0700
Message-ID: <20060718175747.GA22735@us.ibm.com>
References: <20060718152016.GA13642@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:64170 "EHLO
	e36.co.us.ibm.com") by vger.kernel.org with ESMTP id S932333AbWGRR5Z
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jul 2006 13:57:25 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k6IHvO9i017659
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 18 Jul 2006 13:57:25 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k6IHvOWZ156078
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 18 Jul 2006 11:57:24 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6IHvNZr012855
	for <netdev@vger.kernel.org>; Tue, 18 Jul 2006 11:57:24 -0600
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Content-Disposition: inline
In-Reply-To: <20060718152016.GA13642@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 18, 2006 at 11:20:17AM -0400, Lennart Sorensen wrote:
> I am currently doing some testing on my system and managing to totally
> hang the system (so that the watchdog has to come along and reboot it).
> 
> The setup is this:
> I have a PLX PCI-PCI bridge with 4 79C972 chips behind it, each running
> 100baseTX.  I am transmitting traffic from a smartbits test system from
> port 1 to port 3 and back, and from port 2 to port 4 and back.  I am
> running 500 packets/second with 60 byte packets each way.

I don't know what a 'smartbits test system' is or how it works.  Could
you please briefly explain what it is and does?

> 
> If I start the traffic on all 4 ports at the same time, I get less than
> 100 packets received back at the smartbits on each port, and then the
> linux kernel is hung.  No response to anything I have tried.  The
> watchdog then reboots the system.
> 
> If I start traffic on less than 4 ports, and then add the remaining
> ports a second or so later, then it runs just fine and keeps up with the
> traffic.
> 
> I tried making the traffic all flow out eth0 (an rtl8139 port) instead
> of out the pcnet32 ports, and then there is no problem, so I think there
> is some problem when multiple ports try to start transmitting at the
> same time.

Is the rdl8139 on the same PCI bus?

> 
> So far it has failed with 2.6.8 and 2.6.16 and with 2.6.17's pcnet32
> with the napi patches applied.

Is there a version of the pcnet32 driver that does work?  Is this a
stock driver or do you have modifications made as well?

> 
> I noticed that sometime between 2.6.4 and 2.6.8, the TxDone interrupts
> were removed entirely, where as they used to be sent every once in a
> while.  I am not sure if this is making a difference yet.

The ltint or TxDone interrupt deferral code was removed in May 2004,
2.6.7 timeframe.  Every transmit packet causes an interrupt, rather than
just occasionally.

> 
> I tried increasing the ring sizes to their maximum setting of 9/9 rather
> than the current default of 4/5, and that didn't make any difference
> either.

Does reducing the ring size make any difference?  Or tx large/rx small,
or vice-versa?

> 
> Does anyone have a suggestion for how to go about debuging this issue?
> So far I am very confused.

Is there any way to see what is happening on the PCI bus where the
pcnet32 devices are connected?  Or see what is happening on the master
side of the pci-to-pci bridge?  Do the chips share any interrupt lines
or do they all have dedicated irq's?

Is this an SMP or UP system?

> 
> I tried turning on lots of debuging in pcnet32, but that seems to slow
> the system down enough (printing debug messages on the serial console)
> that it only manages to transmit 10 packets per port per second, at
> which point it doesn't lock up.  Reducing the test setting from 500
> 60byte packets/second to 100 makes the problem disappear as well.
> 
> So I am open for suggestions to try.  I really don't know where to go
> about debuging this when it makes the kernel lock up.  It makes me think
> it is getting stuck somewhere with interrupts disabled, but I can't see
> anything in the transmit code that looks like that could happen.
> 
> --
> Len Sorensen
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Don Fry
brazilnut@us.ibm.com
