From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: Re: [PATCH v4 3/4] can: kvaser_usb: Add support for the Usbcan-II
 family
Date: Sun, 18 Jan 2015 15:12:21 -0500
Message-ID: <20150118201221.GA15143@linux>
References: <20141223154654.GB6460@vivalin-002>
 <20150111200544.GA8855@linux>
 <20150111201116.GB8855@linux>
 <20150111201519.GC8855@linux>
 <20150111203612.GA8999@linux>
 <20150112135302.GB18351@hposo>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Olivier Sobrie <olivier@sobrie.be>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150112135302.GB18351@hposo>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

On Mon, Jan 12, 2015 at 02:53:02PM +0100, Olivier Sobrie wrote:
> Hello,
> 
> On Sun, Jan 11, 2015 at 03:36:12PM -0500, Ahmed S. Darwish wrote:
> > From: Ahmed S. Darwish <ahmed.darwish@valeo.com>
> > 

...

> > @@ -98,7 +128,13 @@
> >  #define CMD_START_CHIP_REPLY		27
> >  #define CMD_STOP_CHIP			28
> >  #define CMD_STOP_CHIP_REPLY		29
> > -#define CMD_GET_CARD_INFO2		32
> > +#define CMD_READ_CLOCK			30
> > +#define CMD_READ_CLOCK_REPLY		31
> 
> These two defines are not used.
> 

They were added for completeness: the only gap in our continuous
sequence of command IDs from 12 to 39 ;-) No big deal, to be
removed in the next submission.

...

> > +
> > +struct kvaser_msg_tx_acknowledge_header {
> > +	u8 channel;
> > +	u8 tid;
> > +};
> 
> Is this struct really needed? Can't you simply use
> leaf_msg_tx_acknowledge or usbcan_msg_tx_acknowledge
> structures to read the header.
> Same for kvaser_msg_rx_can_header.
> 

They're added to ensure type-safety throughout the code. Basically
they're the common part of a command that has different wire format
between the Leaf and the USBCan, but share a common header.  Such
notation was only added when it was strictly necessary.

For example, there are three functions where 'rx_can_header' is
referenced in the driver, and one function where 'tx_acknowledge_header'
is referenced. Without such header structure, I'll have to sprinkle
3 to 4 extra blocks of:

	switch (dev->family) {
	       case KVASER_LEAF: 
	       case KVASER_USBCAN:
	}

which would be _really_ ugly. The *_header notation ensures that, in
the body of each function, we're accessing the fields in a very safe
manner.

Thanks,
Darwish
