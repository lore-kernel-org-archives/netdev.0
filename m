From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [Prism54-devel] Re: TxDescriptors -> 1024 default. Please not for every NIC!
Date: Thu, 20 May 2004 09:38:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040520163811.GA15832@bougret.hpl.hp.com>
References: <OF72607111.CD0234C8-ON85256DA1.0068861B-86256DA1.0068FF60@us.ibm.com> <Pine.LNX.4.58.0405151354220.9894@fcat> <Pine.LNX.4.58.0405190256010.30653@fcat> <20040519102700.GA16465@ee.oulu.fi> <20040520141111.GR13898@ruslug.rutgers.edu>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Pietikainen <pp@ee.oulu.fi>, Marc Herbert <marc.herbert@free.fr>,
        netdev@oss.sgi.com, prism54-devel@prism54.org
Content-Disposition: inline
In-Reply-To: <20040520141111.GR13898@ruslug.rutgers.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 20, 2004 at 10:11:11AM -0400, Luis R. Rodriguez wrote:
> On Wed, May 19, 2004 at 01:27:00PM +0300, Pekka Pietikainen wrote:
> > On Wed, May 19, 2004 at 11:30:28AM +0200, Marc Herbert wrote:
> > > - Me argues that we all lived happy for ages with this default
> > >   setting of 100?packets @?100?Mb/s (and lived approximately happy @
> > >   10 Mb/s), but we'll soon see doom and gloom with this new and
> > >   brutal change to 1000?packets for all this _legacy_ 10-100 Mb/s
> > >   hardware. e1000 data only is not enough to justify this radical
> > >   shift.
> > > 
> > > If you are convinced by _both_ items above, then the patch below
> > > content _both_, and we're done.
> > > 
> > > If you are not, then... wait for further discussion, including answers
> > > to latest Ricardo's post.
> >
> > Not to mention that not all modern hardware is gigabit, current
> > 2.6 seems to be setting txqueuelen of 1000 for 802.11 devices too (at least
> > my prism54), which might be causing major problems for me.
> 
> Considering 802.11b's peak is at 11Mbit and standard 802.11g is at 54Mbit
> (some manufacturers are using two channels and getting 108Mbit now) I'd
> think we should stick at 100, as the patch proposes. Jean?
> 
> 	Luis

	I never like to have huge queues of buffers. It waste memory,
and degrade the latency, especially with competing sockets. In a
theoritical stable system, you don't need buffers (you run everything
synchronously), buffer are only needed to take care of the jitter in
real networks.
	The real throughouput of 802.11g is more around 30Mb/s (at
TCP/IP level). However, wireless networks tend to have more jitter
(interference and contention). But, wireless cards tend to have a fair
number of buffers in the hardware.
	I personally would stick with 100. The IrDA stack runs
perfectly fine with 15 buffers at 4 Mb/s. If 100 is not enough, I
think the problem is not the number of buffers, but somewhere else.
For example, we might want to think about explicit socket callbacks
(like I did in IrDA).
	But that's only personal opinions ;-)

	Have fun...

	Jean
