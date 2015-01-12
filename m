From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: Re: [PATCH v4 3/4] can: kvaser_usb: Add support for the Usbcan-II
 family
Date: Mon, 12 Jan 2015 07:36:36 -0500
Message-ID: <20150112123636.GE9213@linux>
References: <20141223154654.GB6460@vivalin-002>
 <20150111200544.GA8855@linux>
 <20150111201116.GB8855@linux>
 <20150111201519.GC8855@linux>
 <20150111203612.GA8999@linux>
 <54B3B37C.7090002@pengutronix.de>
 <20150112120741.GC9213@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	"David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150112120741.GC9213@linux>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 12, 2015 at 07:07:41AM -0500, Ahmed S. Darwish wrote:
> Hi Marc,
> 
> On Mon, Jan 12, 2015 at 12:43:56PM +0100, Marc Kleine-Budde wrote:
> > On 01/11/2015 09:36 PM, Ahmed S. Darwish wrote:
> > > +
> > > +	switch (dev->family) {
> > > +	case KVASER_LEAF:
> > > +		rx_msg = msg->u.leaf.rx_can.msg;
> > > +		break;
> > > +	case KVASER_USBCAN:
> > > +		rx_msg = msg->u.usbcan.rx_can.msg;
> > > +		break;
> > > +	default:
> > > +		dev_err(dev->udev->dev.parent,
> > > +			"Invalid device family (%d)\n", dev->family);
> > >  		return;
> > 
> > should not happen.
> > 
> 
> Yes, but otherwise I get GCC warnings of 'rx_msg' possibly
> being unused. I can add __maybe_unused to rx_msg of course,
> but such annotation may hide possible errors in the future.
> 

Ah, what I meant is using uninitialized_var() to suppress the
GCC warning. But, really, using that macro has a bad history
of hiding errors in the future.

Kindly check http://lwn.net/Articles/529954/ for context.

Another solution might be initializing rx_msg to NULL.

> > > +	switch (dev->family) {
> > > +	case KVASER_LEAF:
> > > +		msg_tx_can_flags = &msg->u.tx_can.leaf.flags;
> > > +		break;
> > > +	case KVASER_USBCAN:
> > > +		msg_tx_can_flags = &msg->u.tx_can.usbcan.flags;
> > > +		break;
> > > +	default:
> > > +		dev_err(dev->udev->dev.parent,
> > > +			"Invalid device family (%d)\n", dev->family);
> > > +		goto releasebuf;
> > should not happen, please remove
> 
> Like the 'rx_msg' case above.
> 
> Thanks,
> Darwish
