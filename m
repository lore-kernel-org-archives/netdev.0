From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: Please pull 'z1211' branch of wireless-2.6
Date: Sat, 22 Sep 2007 14:11:11 +0200
Message-ID: <200709221411.12128.mb@bu3sch.de>
References: <20070919181005.GB5483@tuxdriver.com> <20070920134730.GC6748@tuxdriver.com> <20070922094800.GB12327@deine-taler.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070922094800.GB12327-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Saturday 22 September 2007 11:48:00 Ulrich Kunitz wrote:
> A real high-quality driver will require Johannes' proposed
> mac80211 driver interface changes to be merged and TX
> confirmations handled in a way, that the semantics can really be
> supported by the driver. (Michael Buesh's patch is taping over the
> issue.)

No it is not. It is fixing the issue. It fixes the following issues:
* You must ignore the Txstat-requested bit in the driver.
* You must report bad frames with the excessive_retries set.

The issue you are (most likely) talking about is that we can not
reliably tell whether a frame was good in the driver. That is a different
issue completely seperate from the two points above, which my patch fixes.

With my patch rate-controlling correctly works. Without it does not.

If you find a way to fix the reliable-detection-of-good-TX issue, that's
another good fix. But I think it's not release critical, because the
device works with the current "guessing-around" code. But without the two
points above fixed, it does not correctly work at all (unless you manually
tune to the best rate each time you move the machine).

-- 
Greetings Michael.
