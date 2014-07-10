From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 2/2] hso: fix deadlock when receiving bursts of data
Date: Thu, 10 Jul 2014 15:55:16 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17270187@AcuExch.aculab.com>
References: <1404723967-24245-1-git-send-email-olivier@sobrie.be>
	<1404723967-24245-2-git-send-email-olivier@sobrie.be>
	<20140708.161633.2130069042930765600.davem@davemloft.net>
	<20140710142848.GA28056@hposo>
	<063D6719AE5E284EB5DD2968C1650D6D17270044@AcuExch.aculab.com>
 <20140710165003.0309924e@alan.etchedpixels.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: 'Olivier Sobrie' <olivier@sobrie.be>,
	David Miller <davem@davemloft.net>,
	"j.dumon@option.com" <j.dumon@option.com>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'One Thousand Gnomes' <gnomes@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140710165003.0309924e@alan.etchedpixels.co.uk>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: One Thousand Gnomes
> On Thu, 10 Jul 2014 14:37:37 +0000
> David Laight <David.Laight@ACULAB.COM> wrote:
> 
> > From: Olivier Sobrie
> > ...
> > > The function put_rxbuf_data() is called from the urb completion handler.
> > > It puts the data of the urb transfer in the tty buffer with
> > > tty_insert_flip_string_flags() and schedules a work queue in order to
> > > push the data to the ldisc.
> > > Problem is that we are in a urb completion handler so we can't wait
> > > until there is room in the tty buffer.
> 
> The tty provides the input queue, if the queue is full then just chuck
> the data in the bitbucket.  hso is trying to be far too clever.
> 
> If hso is fast enough that the buffering isn't sufficient on the tty side
> then we need to fix the tty buffer size.

You really want to apply flow control back over the 'serial' link.
That may just cause data discards earlier on the local system.
But it is possible that not resubmitting the receive urb will cause the
modem to flow control back to the sender.
In which case there is some chance that data won't be lost.

	David

> 
> Arguably what we need are tty fastpaths for non N_TTY but thats rather
> more work. There's no fundamental reason that hso can't throw the buffer
> at buffer straight at the PPP ldisc and straight into the network stack -
> just that
> 
> 1. The tty mid layer glue is standing in the way
> 2. The change of line discipline code has to lock against it
> 
> Alan
