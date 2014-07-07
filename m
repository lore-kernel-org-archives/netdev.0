From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 2/2] hso: fix deadlock when receiving bursts of data
Date: Mon, 7 Jul 2014 12:55:44 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1726D772@AcuExch.aculab.com>
References: <1404723967-24245-1-git-send-email-olivier@sobrie.be>
 <1404723967-24245-2-git-send-email-olivier@sobrie.be>
 <063D6719AE5E284EB5DD2968C1650D6D1726D5E9@AcuExch.aculab.com>
 <20140707104220.GA31340@hposo>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Jan Dumon <j.dumon@option.com>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Olivier Sobrie' <olivier@sobrie.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140707104220.GA31340@hposo>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Olivier Sobrie 
> Hi David,
> 
> On Mon, Jul 07, 2014 at 09:13:53AM +0000, David Laight wrote:
> > From: Olivier Sobrie
> > > When the module sends bursts of data, sometimes a deadlock happens in
> > > the hso driver when the tty buffer doesn't get the chance to be flushed
> > > quickly enough.
> > >
> > > To avoid this, first, we remove the endless while loop in
> > > put_rx_bufdata() which is the root cause of the deadlock.
> > > Secondly, when there is no room anymore in the tty buffer, we set up a
> > > timer of 100 msecs to give a chance to the upper layer to flush the tty
> > > buffer and make room for new data.
> >
> > What is the timer for?
> > You need to get the sending code woken up by the urb completion.
> 
> In put_rxbuf_data() (which can be called under irq disabled),
> tty_flip_buffer_push() is called and schedules a push of the tty buffer.
> When the buffer is full, I give some time to the above layer in order
> to flush it.
> The timer is used to recall put_rxbuf_data_and_resubmit_bulk_urb()
> later in order to read the remaining data stored in
> "urb->transfer_buffer" and then to resubmit the urb to receive more data
> from the gsm module.
> I don't understand what you mean by "getting the sending code woken up".
> Calling tty_port_tty_wakeup()?? We are in the receive path...

Sorry, it isn't at all clear from the general description whether you
are referring to the transmit or receive path.

'flush' can mean all sorts of things ...

In either case a 100ms delay to data doesn't seem right at all.

	David
