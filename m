From: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH 2/2] hso: fix deadlock when receiving bursts of data
Date: Fri, 11 Jul 2014 09:28:47 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1727090C@AcuExch.aculab.com>
References: <1404723967-24245-1-git-send-email-olivier@sobrie.be>
 <1404723967-24245-2-git-send-email-olivier@sobrie.be>
 <20140708.161633.2130069042930765600.davem@davemloft.net>
 <20140710142848.GA28056@hposo>
 <063D6719AE5E284EB5DD2968C1650D6D17270044@AcuExch.aculab.com>
 <20140710165003.0309924e@alan.etchedpixels.co.uk>
 <20140711091803.GA19663@hposo>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org" <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: 'Olivier Sobrie' <olivier-Ui3EtX6WB9GzQB+pC5nmwQ@public.gmane.org>,
	One Thousand Gnomes <gnomes-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140711091803.GA19663@hposo>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Olivier Sobrie Olivier Sobrie
> Hi Alan and Davids,
> 
> On Thu, Jul 10, 2014 at 04:50:03PM +0100, One Thousand Gnomes wrote:
> > On Thu, 10 Jul 2014 14:37:37 +0000
> > David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org> wrote:
> >
> > > From: Olivier Sobrie
> > > ...
> > > > The function put_rxbuf_data() is called from the urb completion handler.
> > > > It puts the data of the urb transfer in the tty buffer with
> > > > tty_insert_flip_string_flags() and schedules a work queue in order to
> > > > push the data to the ldisc.
> > > > Problem is that we are in a urb completion handler so we can't wait
> > > > until there is room in the tty buffer.
> >
> > The tty provides the input queue, if the queue is full then just chuck
> > the data in the bitbucket.  hso is trying to be far too clever.
> >
> > If hso is fast enough that the buffering isn't sufficient on the tty side
> > then we need to fix the tty buffer size.
> 
> Ok I'll adapt the patch to drop the data that can't be put in the tty
> buffer. I test this and resend a new patch.

If you are going to drop data, then ideally you want to discard entire ppp
packets. Depending on exactly how the interface works it might be that
urb are likely to contain complete packets.

So discarding entire urb might work better than discarding a few bytes.
(But don't even think of scanning the data stream in the usb driver - except
for experiments.)

	David



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
