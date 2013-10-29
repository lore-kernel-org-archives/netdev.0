From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2] can: c_can: Speed up rx_poll function
Date: Tue, 29 Oct 2013 09:24:05 -0700
Message-ID: <1383063845.2713.15.camel@joe-AO722>
References: <1383035267-19604-1-git-send-email-mpa@pengutronix.de>
	 <1383035688.2713.2.camel@joe-AO722> <20131029085853.GC20839@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	Wolfgang Grandegger <wg@grandegger.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel@pengutronix.de
To: Markus Pargmann <mpa@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131029085853.GC20839@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-10-29 at 09:58 +0100, Markus Pargmann wrote:
> On Tue, Oct 29, 2013 at 01:34:48AM -0700, Joe Perches wrote:
> > On Tue, 2013-10-29 at 09:27 +0100, Markus Pargmann wrote:
> > > This patch speeds up the rx_poll function by reducing the number of
> > > register reads.
> > []
> > > 125kbit:
> > >   Function                               Hit    Time            Avg             s^2
> > >   --------                               ---    ----            ---             ---
> > >   c_can_do_rx_poll                     63960    10168178 us     158.977 us      1493056 us
> > > With patch:
> > >   c_can_do_rx_poll                     63939    4268457 us     66.758 us       818790.9 us
> > > 
> > > 1Mbit:
> > >   Function                               Hit    Time            Avg             s^2
> > >   --------                               ---    ----            ---             ---
> > >   c_can_do_rx_poll                     69489    30049498 us     432.435 us      9271851 us
> > > With patch:
> > >   c_can_do_rx_poll                    103034    24220362 us     235.071 us      6016656 us
[]
> Yes I just measured the timings again:
[]
> ./perf_can_test.sh 125000 30
[]
>   c_can_do_rx_poll                     63941    3764057 us     58.867 us       776162.2 us 

Good, it's slightly faster still.

> ./perf_can_test.sh 1000000 30
[]
>   c_can_do_rx_poll                    207109    24322185 us     117.436 us      171469047 us 
[]
> It is interesting that the number of hits for c_can_do_rx_poll is twice as much
> as it was with find_next_bit.

How is this possible?  Any idea?
