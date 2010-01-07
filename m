From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Wed, 6 Jan 2010 20:53:43 -0800
Message-ID: <20100106205343.5460d658@nehalam>
References: <20100105230746.GA6612@del.dom.local>
	<4B43F72C.9090004@majjas.com>
	<20100106072208.GA6711@ff.dom.local>
	<4B44E952.5000804@majjas.com>
	<20100106131044.25b4e500@nehalam>
	<4B451C31.3000309@majjas.com>
	<4B454A16.3030909@majjas.com>
	<4B455C62.6030504@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:56360 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752518Ab0AGEyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 23:54:43 -0500
In-Reply-To: <4B455C62.6030504@majjas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 06 Jan 2010 23:00:34 -0500
Michael Breuer <mbreuer@majjas.com> wrote:

> Changing MTU to 9000, everything basically breaks - Can't use X11 (local 
> or remote - get X11 screen after gdm login locally, but then goes back 
> to greeter; remote gets no greeter); ssh sessions hang; etc. This time I 
> was able to reset the MTU back to 1500 without a reboot - but I did have 
> to ifconfig eth0 down and then up. Looking at the sk98lin code, it looks 
> to me like they do a bit more work with existing buffers before 
> completing the MTU switch. Note that even doing this, X11 did not work 
> (it did with the old mtu change code). Tried changing to mtu 4500 - same 
> effect as 9000... but when I switched back to 1500, ksoftirqd started 
> spinning using 100% of one core.

The problem is that patch was enabling scatter-gather and checksum offload
that won't work on EC_U hardware with 9K MTU.  At least, it never worked
for me when I tested it. So because of that it really doesn't change anything
for the better on that chip version.

What version chip is on that motherboard?  Mine is:
 Yukon-2 EC Ultra chip revision 3
which corresponds to B0 step.

Another possibility is the PHY register which controls number of ticks
of buffering.  The default is zero, which gives the most buffering (good),
but the firmware could be reprogramming it (bad).  In general, the driver
doesn't fiddle with bits that are already set correctly, because sometimes
vendors need to tweak PCI timing in firmware/BIOS.  It seems the firmware on this
chip is just a bunch of register setups done on power on.
