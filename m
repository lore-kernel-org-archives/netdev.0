From: Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>
Subject: Re: Please pull 'z1211' branch of wireless-2.6
Date: Sat, 22 Sep 2007 16:42:54 +0200
Message-ID: <20070922144254.GB12907@deine-taler.de>
References: <20070919181005.GB5483@tuxdriver.com> <20070920134730.GC6748@tuxdriver.com> <20070922094800.GB12327@deine-taler.de> <200709221411.12128.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <200709221411.12128.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:

> On Saturday 22 September 2007 11:48:00 Ulrich Kunitz wrote:
> > A real high-quality driver will require Johannes' proposed
> > mac80211 driver interface changes to be merged and TX
> > confirmations handled in a way, that the semantics can really be
> > supported by the driver. (Michael Buesh's patch is taping over the
> > issue.)
> 
> No it is not. It is fixing the issue. It fixes the following issues:

> * You must ignore the Txstat-requested bit in the driver.

If that is really the case the flag should be removed from
mac80211. There is no way for somebody looking at the code to know
this.

> * You must report bad frames with the excessive_retries set.

All bad frames or only those with actual excessive retries? Your patch
set the excessive_retries flag for packets that couldn't be
transmitted to the device because of an USB error. If the flag
should be set for all kinds of errors it should be renamed.

> The issue you are (most likely) talking about is that we can not
> reliably tell whether a frame was good in the driver. That is a different
> issue completely seperate from the two points above, which my patch fixes.

This has been the reason, why I stated "taped over".

The issues are:

* The driver cannot reliably tell, whether the transmission of
  particular packet to the same address failed but is forced by
  mac80211 to pretend this.
* Currently the device reports ACKs over the USB interface, which
  increases the interrupt load. The ACKs can also not reliably
  paired with the transmitted packet. Sending only one packet in parallel
  per destination address to the device and wait for a timeout
  would slow things down.

I would like to see that the driver would only be required to
report the status for single packets in critical phases like
associations. In other situations the driver should only be
requested to support statistics.

> With my patch rate-controlling correctly works. Without it does not.
> If you find a way to fix the reliable-detection-of-good-TX issue, that's
> another good fix. But I think it's not release critical, because the
> device works with the current "guessing-around" code. But without the two
> points above fixed, it does not correctly work at all (unless you manually
> tune to the best rate each time you move the machine).

Your patch clearly fixed the problem of the missing excessive
retries flag. But it should be accomponied by patches of
mac80211. One could fix the request-tx-status flag situation.
Another could rename the excessive_retries flag to tx_error.

-- 
Uli Kunitz
