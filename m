From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 02/12] net: axienet: Handle 0 packet receive gracefully
Date: Tue, 05 May 2015 11:53:49 -0700
Message-ID: <1430852029.6575.13.camel@perches.com>
References: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
	 <55b3c89b3549c61d62b8440636516fd572870842.1430817941.git.michal.simek@xilinx.com>
	 <1430834264.7191.9.camel@perches.com> <554910D1.1030706@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Peter Crosthwaite <peter.crosthwaite@xilinx.com>,
	=?ISO-8859-1?Q?S=F6ren?= Brinkmann <soren.brinkmann@xilinx.com>,
	monstr@monstr.eu, John Linn <John.Linn@xilinx.com>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Michal Simek <michal.simek@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <554910D1.1030706@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-05-05 at 20:49 +0200, Michal Simek wrote:
> On 05/05/2015 03:57 PM, Joe Perches wrote:
> > On Tue, 2015-05-05 at 11:25 +0200, Michal Simek wrote:
> >> From: Peter Crosthwaite <peter.crosthwaite@xilinx.com>
> >>
> >> The AXI-DMA rx-delay interrupt can sometimes be triggered
> >> when there are 0 outstanding packets received. This is due
> >> to the fact that the receive function will greedily consume
> >> as many packets as possible on interrupt. So if two packets
> >> (with a very particular timing) arrive in succession they
> >> will each cause the rx-delay interrupt, but the first interrupt
> >> will consume both packets.
> >> This means the second interrupt is a 0 packet receive.
> >>
> >> This is mostly OK, except that the tail pointer register is
> >> updated unconditionally on receive. Currently the tail pointer
> >> is always set to the current bd-ring descriptor under
> >> the assumption that the hardware has moved onto the next
> >> descriptor. What this means for length 0 recv is the current
> >> descriptor that the hardware is potentially yet to use will
> >> be marked as the tail. This causes the hardware to think
> >> its run out of descriptors deadlocking the whole rx path.
> >>
> >> Fixed by updating the tail pointer to the most recent
> >> successfully consumed descriptor.
> > 
> > I think some of this would be good to have as comments
> > in the code instead of just in the changelog.
> Is it really needed? If yes, no problem to add it but git blame can
> point you to that.

That's up to you.

I think that useful but concealed information is
always hard to follow or find.
