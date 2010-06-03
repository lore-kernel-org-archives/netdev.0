From: Mitchell Erblich <erblichs@earthlink.net>
Subject: Proposed linux kernel changes : scaling  tcp/ip stack
Date: Thu, 3 Jun 2010 01:16:54 -0700
Message-ID: <FDFFEFAB-A741-4232-821E-17BFAE5CAFAC@earthlink.net>
Mime-Version: 1.0 (Apple Message framework v1078)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-mealy.atl.sa.earthlink.net ([209.86.89.69]:39570 "EHLO
	elasmtp-mealy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750811Ab0FCIQ6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jun 2010 04:16:58 -0400
Received: from [71.202.111.27] (helo=[192.168.1.2])
	by elasmtp-mealy.atl.sa.earthlink.net with esmtpsa (TLSv1:AES128-SHA:128)
	(Exim 4.67)
	(envelope-from <erblichs@earthlink.net>)
	id 1OK5bk-0002Vk-3X
	for netdev@vger.kernel.org; Thu, 03 Jun 2010 04:16:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To whom it may concern,

First, my assumption is to keep this discussion local to just a few tcp/ip
developers to see if there is any consensus that the below is a logical 
approach. Please also pass this email if there is a "owner(s)" of this stack
to identify if a case exists for the below possible changes.

I am not currently on the linux kernel mail group.
			
I have experience with modifications of the Linux tcp/ip stack, and have
merged the changes into the company's local tree and left the possible 
global integration to others.

I have been approached by a number of companies about scaling the
stack with the assumption of a number of cpu cores. At present, I find extra
time on my hands and am considering looking into this area on my own.

The first assumption is that if extra cores are available, that a single
received homogeneous flow of a large number of packets/segments per
second (pps) can be split into non-equal flows. This split can in effect
allow a larger recv'd pps rate at the same core load while splitting off
other workloads, such as xmit'ing pure ACKs.

Simply, again assuming Amdahl's law (and not looking to equalize the load
between cores), and creating logical separations where in a many core 
system, different cores could have new kernel threads  that operate in 
parallel within the tcp/ip stack. The initial separation points would be at 
the ip/tcp layer boundry and where any recv'd sk/pkt would generate some 
form of output.

The ip/tcp layer would be split like the vintage AT&T STREAMs protocol,
with some form of queuing & scheduling, would be needed. In addition,
the queuing/schedullng of other kernel threads would occur within ip & tcp
to separate the I/O.

A possible validation test is to identify the max recv'd pps rate within the
tcp/ip modules within normal flow TCP established state with normal order 
of say 64byte non fragmented segments, before and after each 
incremental change. Or the same rate with fewer core/cpu cycles.

I am willing to have a private git Linux.org tree that concentrates proposed
changes into this tree and if there is willingness, a seen want/need then identify
how to implement the merge.

		Mitchell Erblich
		UNIX Kernel Engineer