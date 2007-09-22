From: Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>
Subject: Re: Please pull 'z1211' branch of wireless-2.6
Date: Sat, 22 Sep 2007 11:48:00 +0200
Message-ID: <20070922094800.GB12327@deine-taler.de>
References: <20070919181005.GB5483@tuxdriver.com> <46F19DD0.2050605@gentoo.org> <20070920134730.GC6748@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070920134730.GC6748-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Sorry for joining the discussion so late, but I have a day job
requires sometimes all of my time.

John W. Linville wrote:

> On Wed, Sep 19, 2007 at 11:08:16PM +0100, Daniel Drake wrote:
> 
> > I would like to this until 2.6.25 until I have had time to clear up some 
> > final issues and do more testing myself of zd1211rw-mac80211. I also 
> > think we need to discuss the rename...
> 
> Renames being what they are, I was hoping to avoid a "bikeshed"
> discussion about the choice of names.  My main point was to get it
> into the tree with a unique and manageable name.  I'm sure we could
> still rename it again before 2.6.24 ships or even later.

I would remark here that names are important. John you are
suggesting here the fourth rename of the mac80211 zd1211rw driver.
In my professional life I would clearly identify this as a
problem. I agree that zd1211rw-mac80211 is awkward, but this name
hasn't been  introduced by Daniel or me. z1211 has never been used
to refer to the device. If a new name for zd1211rw-mac80211 has to
be found, we should use zd1211mac. This is a different name than
the for the softmac driver, which is zd1211rw. This should also
clarify my personal position, which is that different things
should be named differently. We cannot use zd1211, because this is
used by the out-of-tree vendor driver, which is still used by some
people.

> Well, obviously I would like to get it out now.  The longer we are
> without a mac80211-based driver for zd1211 hardware then the longer
> we must maintain the softmac component (or at least take bug reports
> for it).

The problem from my perspective is, that mac80211 and our driver
is not there where it should be. Actually the softmac driver still
works better than the mac80211 driver. There are sometimes stops
with mac80211 for several seconds, which is pretty painful while
remotely editing text, which I do right now. Yes, I eat my own dog
food. The reason is that mac80211 has assumptions about the
features a device supports that we emulate quite badly, because
the device interface doesn't support the required semantics. (TX
confirmations is my major concern right now.) Multiple interfaces
don't work and I have been able to cause kernel crashes while
playing around with this. The driver doesn't support the setting
of certain configuration parameters while the device is down.
(Personally I think that should be handled by the stack, but it
doesn't right now.) We are receiving complains about kismet
compatibility once in a while.

You could ask, why we have not fixed those things. The problem is
that mac80211 right now is a moving target. I spent two weekends
simply to identify the patch, that caused a complete crash of the
kernel with the driver. At the same time the wireless-dev tree
reorg has been done, which destroyed the whole history. I wrote my
own git patch tool to be able to bisect. I found the patch, it had
around 2000 changed lines, it mixed code moves and some quick
fixes. Shortly afterwards a patch by Johannes fixed the problem. I
had not changed a line of the driver, but had spend around 50
hours on the problem. I apologize for the ranting. But I sometimes
feel, that Linux development is done under the assumption that
everybody has tons of midnight oil to burn. 

Daniel and I are testing and reviewing every patch we are
forwarding to the wireless mailing list. It's not nice to spend
one to two hours again to adapt and test the pending patches,
because somebody has renamed the driver directory again.

> If you are determined not to have it in 2.6.24 then I will relent.
> I will also suggest that Larry start sending any softmac bugs to
> you... :-)

I think I have ranted enough. :-)
> 
> If we will be having a port rather than a new driver, how soon after
> 2.6.24-rc1 closes can we queue the port for 2.6.25?  I think it
> should be almost immediately, to ensure maximum test exposure and to
> "seal the deal".  What do you think?

My minimum criteria for mainline inclusion are:

1) The driver doesn't crash anymore while playing around with
   multiple interfaces. (I have to check this.)
2) A reasonable name has been chosen. My suggestion is zd1211mac.

A real high-quality driver will require Johannes' proposed
mac80211 driver interface changes to be merged and TX
confirmations handled in a way, that the semantics can really be
supported by the driver. (Michael Buesh's patch is taping over the
issue.)

Thanks,

Uli

-- 
Uli Kunitz
