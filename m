From: Jon Wikne <wikne@cheetah.uio.no>
Subject: Re: [RFT] sky2: transmit complete alternative
Date: Wed, 23 Aug 2006 12:06:00 +0200
Message-ID: <44EC2888.7040005@cheetah.uio.no>
References: <44E9A9E0.20106@cheetah.uio.no>	<44E9B28C.9050207@gentoo.org>	<44E9C153.1010300@cheetah.uio.no>	<20060821095116.1b7f725d@localhost.localdomain>	<44EA2DD7.9060605@cheetah.uio.no> <20060822153841.1832f690@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.4]:48333 "EHLO pat.uio.no")
	by vger.kernel.org with ESMTP id S964809AbWHWKGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 06:06:12 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060822153841.1832f690@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Does the following get rid of the hang?
> --------
> Recode the transmit completion handling to avoid races between the hardware
> status report mechanism and the interrupt handler. Rather than relying on
> the index value in the status ring, read the chip register and cleanup
> all completed transmits. 
> 
> Reduce the transmit lock window smaller to allow more parallelism.

[ patch ]

I'm afraid not. :-(

1) The number of bytes before the hang occurs seems to have _decreased_
    rather than the opposite. This observation is, however, a question
    of statistics, and I have better such with the previous version.

2) Previously, the sequence /sbin/ifdown eth0 - /sbin/ifup eth0 made
    the driver recover. Now, the latter of these commands hangs the
    whole system. The recovery is now /sbin/ifdown eth0 - rmmod sky2
    - modprobe sky2


-- Jon

