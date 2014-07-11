From: Olivier Sobrie <olivier@sobrie.be>
Subject: Re: [PATCH 2/2] hso: fix deadlock when receiving bursts of data
Date: Fri, 11 Jul 2014 11:18:03 +0200
Message-ID: <20140711091803.GA19663@hposo>
References: <1404723967-24245-1-git-send-email-olivier@sobrie.be>
 <1404723967-24245-2-git-send-email-olivier@sobrie.be>
 <20140708.161633.2130069042930765600.davem@davemloft.net>
 <20140710142848.GA28056@hposo>
 <063D6719AE5E284EB5DD2968C1650D6D17270044@AcuExch.aculab.com>
 <20140710165003.0309924e@alan.etchedpixels.co.uk>
Reply-To: Olivier Sobrie <olivier@sobrie.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
	David Miller <davem@davemloft.net>,
	"j.dumon@option.com" <j.dumon@option.com>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140710165003.0309924e@alan.etchedpixels.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Alan and Davids,

On Thu, Jul 10, 2014 at 04:50:03PM +0100, One Thousand Gnomes wrote:
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

Ok I'll adapt the patch to drop the data that can't be put in the tty
buffer. I test this and resend a new patch.

Thanks for your help!

-- 
Olivier
