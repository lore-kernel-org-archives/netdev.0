From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [RFC] Best method to control a "transmit-only" mode on fiber
 NICs (specifically sky2)
Date: Fri, 15 Feb 2008 22:24:36 -0800
Message-ID: <47B681A4.80803@vyatta.com>
References: <f73f7ab80802151941x5daf34e3scd0f42a05291db51@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux NetDev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Kyle Moffett <kyle@moffetthome.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:42028 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763597AbYBPGYn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Feb 2008 01:24:43 -0500
In-Reply-To: <f73f7ab80802151941x5daf34e3scd0f42a05291db51@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kyle Moffett wrote:
> Hi,
>
> The company I'm working for has an unusual fiber NIC configuration
> that we use for one of our network appliances.  We connect only a
> single fiber from the TX port on one NIC to the RX port on another
> NIC, providing a physically-one-way path for enhanced security.
> Unfortunately this doesn't work with most NIC drivers, as even with
> auto-negotiation off they look for link probe pulses before they
> consider the link "up" and are willing to send packets.  We have been
> able to use Myricom 10GigE NICs with a custom firmware image.  More
> recently we have patched the sky2 driver to turn on the FIB_FORCE_LNK
> flag in the PHY control register; this seems to work on the
> Marvell-chipset boards we have here.
>
> What would be the preferred way to control this "force link" flag?
> Right now we are accessing it using ethtool; we have added an
> additional "duplex" mode: "DUPLEX_TXONLY", with a value of 2.  When
> you specify a speed and turn off autonegotiation ("./patched-ethtool
> -s eth2 speed 1000 autoneg off duplex txonly"), it will turn on the
> specified bit in the PHY control register and the link will
> automatically come up.  We also have one related bug-fix^Wdirty hack
> for sky2 to reset the PHY a second time during netif-up after enabling
> interrupts; otherwise the immediate "link up" interrupt gets lost.
> Once I get approval from the company I will patch the post itself for
> review.
>
> I look forward to your comments and suggestions
>
> Cheers,
> Kyle Moffett
>   
For the second problem, you could just change the code to check the 
status immediately,
by calling the same code the irq does. It might need some refactoring 
but should only be minor surgery.
I was thinking about doing that anyway for the forced link (no 
negotiation case).

