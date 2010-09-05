From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/2] [RFC] posix clock tuning
Date: Sun, 5 Sep 2010 18:13:33 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1009051759100.3480@router.home>
References: <cover.1283504065.git.richard.cochran@omicron.at> <alpine.DEB.2.00.1009041221240.888@router.home> <4C828652.4060804@gmail.com> <alpine.DEB.2.00.1009042042130.9425@router.home> <20100905062240.GB2699@riccoc20.at.omicron.at>
 <20100905072041.GA2928@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Christian Riesch <christian.riesch@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-api@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100905072041.GA2928@riccoc20.at.omicron.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 5 Sep 2010, Richard Cochran wrote:

> Again, I meant "PTP hardware clocks."
>
> When I get some more time, I'll try to put together an executive
> summary of PTP and of all the discussions that have taken place over
> the last few months on linux-netdev and the lkml.

I know PTP, I just dont know why you would need to extend the existing
apis for support. Maybe you could just simply write a PTP clock driver? If
you follow the way hpet is implemented then you dont even need a clock id.
See drivers/char/hpet.c. I cannot imagine why someone would want to set
PTP to a different time and speed (vs. realtime not the hardware
configuration) than the standard clock. The API you proposed so far is
not needed as far as I can tell.

I really would like a PTP clock as soon as possible. Very very important
for time sync via the network.

Then there is CLOCK_SGI_CYCLE. Another hw clock that can be set and gotten
already with the standard posix interface. See drivers/char/mmtimer.c. The
main benefit from CLOCK_SGI_CYCLE is that you can set it manually (maybe
you want an offset to realtime? But I do not know of any usecase for
setting the clock) and that the clock can cause hardware IRQ events
to cause timer timers in user space (would be great to know if PTP needs
this?). The clock is also distributed in the local memory space of
each node. Plus the clock device can be configured in some fashion
(but then hpet also has some ioctls).

I would not think that PTP needs any of this specialized functionality.
John point about not wanting to proliferate different APIs and useless
clock ids is valid. An intial implementation using hpet style stuff would
be satisfactory and as far as I can tell would be rather trivial to do.

Standardizing the ioctls between the different clock drivers would be
useful so that they can all be controlled with some common API. But it
would be great to first have a release of a clock_ptp listing all the
needed ioctl so that we can see what the common subset is.
