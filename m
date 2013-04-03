From: Werner Almesberger <werner@almesberger.net>
Subject: Re: [Linux-zigbee-devel] [PATCH 1/6] mac802154: Immediately retry
 sending failed packets
Date: Tue, 2 Apr 2013 23:38:21 -0300
Message-ID: <20130403023821.GE28141@ws>
References: <1364928481-1813-1-git-send-email-alan@signal11.us>
 <1364928481-1813-2-git-send-email-alan@signal11.us>
 <CAJmB2rCr5ds11+iN=W5GCKsUgdfb57uKg+mH4NY4CWw6EFCTbg@mail.gmail.com>
 <515B3F78.2020301@signal11.us>
 <515B4D79.40805@signal11.us>
 <20130402231319.GD28141@ws>
 <515B84EB.8020006@signal11.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-zigbee-devel <linux-zigbee-devel@lists.sourceforge.net>,
	linux-kernel@vger.kernel.org
To: Alan Ott <alan@signal11.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <515B84EB.8020006@signal11.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Ott wrote:
> 1. Most supported devices have only single packet output buffer, so
> blocking in the driver is the most straight-forward way to handle it.
> The alternative is to make each driver have a workqueue for xmit() (to
> lift the blocking out from atomic context). This makes each driver simpler.

It does make following the program flow a little easier, but
the difference isn't all that large if you think of it,
particularly if you have to wait not only for I/O to finish
but also for the device to send the packet.

The latter will usually be signaled by some form of interrupt,
so you're already in a situation where a callback to the higher
layers of the stack would be very natural.

> Maybe at some point this will be done. Right now we have a ton of
> pressing issues (in my opinion).

Agreed on having no shortage of nasty issues :-) And I'd like
to echo Dave's comment regarding netdev. Those ieee802154_dev
always struck me as peculiar, with flow control just being one
issue.

And things get worse when you have a complex bus underneath
your driver. For example, my USB-using atusb driver (*) has to
do a great many things usbnet already does. And any other
USB-based WPAN driver would be more or less in the same boat.
Of course, one could reinvent that wheel as well and make a
usbwpan, but ... :)

(*) Sneak preview, still with a number of issues, not only style:
    https://github.com/wpwrak/ben-wpan-linux/blob/master/drivers/net/ieee802154/atusb.c

- Werner
