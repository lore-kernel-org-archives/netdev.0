From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH CFT 00/30] Initial round of Freescale FEC ethernet
	patches
Date: Tue, 1 Jul 2014 15:34:01 +0100
Message-ID: <20140701143401.GT32514@n2100.arm.linux.org.uk>
References: <20140627151542.GL32514@n2100.arm.linux.org.uk> <53B2C3E8.7030903@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	Fugang Duan <B38611@freescale.com>
To: Nathan Lynch <Nathan_Lynch@mentor.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:49954 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751854AbaGAOeM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 10:34:12 -0400
Content-Disposition: inline
In-Reply-To: <53B2C3E8.7030903@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 01, 2014 at 09:21:28AM -0500, Nathan Lynch wrote:
> [apologies if this is a duplicate, I got a weird SMTP error from my
> organization's mail server when I tried to send this yesterday]
> 
> On 06/27/2014 10:15 AM, Russell King - ARM Linux wrote:
> > This is v2 of my initial round of patches (roughly half of my total
> > patch set) for the Freescale FEC driver.
> > 
> > I'm sending this set out for comments and testing.  So far, I have
> > had only one ack for one patch in this series, this is pretty poor,
> > so I'm now sending it with a CFT tag instead.
> 
> FWIW I've given your fec-testing branch some testing on BD-SL-i.MX6
> (Sabre Lite) with 3.16-rc2 (-rc1 has some issue with detecting the mmc).
>  Mainly running glibc 'make check' with SSH, NFSv4, IPv4 on a gigabit
> switch.  This workload wasn't exhibiting problems before your patches
> and it does not appear to be regressed by them.
> 
> I wanted to test it because I've noticed hard-to-characterize sluggish
> interactive response in SSH sessions on this system.  Like key echo
> takes 0.2 seconds too long... sometimes.  I guess it could be anything,
> but I haven't encountered it yet with your patches.

Thanks for testing.

Can I add a tested-by tag for you for those patches?

It is still possible for that sluggishness to occur with these patches,
more so as the transmit ring is now soo large - with 512 entries in
the ring, it is theoretically possible to have up to 512 * 1514 = 757KB
of data queued in the ring irrespective of the wire speed.

If the transmit ring has a significant number of large packets queued,
and then your interactive ssh packet comes along, it will be tacked
on the end of the queue, and it will have to wait for all the packets
ahead of it to be transmitted first.

This is where the byte queue limits really help - it provides more
control over the amount of data in the transmit ring, and is designed
to help prevent this kind of issue.

I have such a patch, but it's based upon the work I did on the driver
prior to the merge window, which does not take account of the changes
which happened during the window - it's part of my "second half" of
this series which will be worked on now that the first half is mostly
out of the way.

Thanks again for testing.

David - how would you like to take the patches?  Shall I just re-send
them without the CFT tag To: you?  Do you have anything other than
the IPv6 fix queued up at the moment for this driver?  Thanks.

-- 
FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
improving, and getting towards what was expected from it.
