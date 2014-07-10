From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 2/2] hso: fix deadlock when receiving bursts of data
Date: Thu, 10 Jul 2014 16:50:03 +0100
Message-ID: <20140710165003.0309924e@alan.etchedpixels.co.uk>
References: <1404723967-24245-1-git-send-email-olivier@sobrie.be>
	<1404723967-24245-2-git-send-email-olivier@sobrie.be>
	<20140708.161633.2130069042930765600.davem@davemloft.net>
	<20140710142848.GA28056@hposo>
	<063D6719AE5E284EB5DD2968C1650D6D17270044@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "'Olivier Sobrie'" <olivier@sobrie.be>,
	David Miller <davem@davemloft.net>,
	"j.dumon@option.com" <j.dumon@option.com>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D17270044@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 10 Jul 2014 14:37:37 +0000
David Laight <David.Laight@ACULAB.COM> wrote:

> From: Olivier Sobrie
> ...
> > The function put_rxbuf_data() is called from the urb completion handler.
> > It puts the data of the urb transfer in the tty buffer with
> > tty_insert_flip_string_flags() and schedules a work queue in order to
> > push the data to the ldisc.
> > Problem is that we are in a urb completion handler so we can't wait
> > until there is room in the tty buffer.

The tty provides the input queue, if the queue is full then just chuck
the data in the bitbucket.  hso is trying to be far too clever.

If hso is fast enough that the buffering isn't sufficient on the tty side
then we need to fix the tty buffer size.

Arguably what we need are tty fastpaths for non N_TTY but thats rather
more work. There's no fundamental reason that hso can't throw the buffer
at buffer straight at the PPP ldisc and straight into the network stack -
just that 

1. The tty mid layer glue is standing in the way
2. The change of line discipline code has to lock against it

Alan
