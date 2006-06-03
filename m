From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [linux-usb-devel] [PATCH RFC] ZyDAS ZD1211 USB-WLAN driver
Date: Sun, 4 Jun 2006 00:25:31 +0200
Message-ID: <200606040025.32275.oliver@neukum.org>
References: <44817083.508@gentoo.org> <200606031951.09135.oliver@neukum.org> <4481E497.2000505@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-usb-devel@lists.sourceforge.net,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, Ulrich Kunitz <kune@deine-taler.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.kontent.de ([81.88.34.36]:43743 "EHLO Mail1.KONTENT.De")
	by vger.kernel.org with ESMTP id S1751633AbWFCWZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jun 2006 18:25:16 -0400
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <4481E497.2000505@gentoo.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Samstag, 3. Juni 2006 21:35 schrieb Daniel Drake:
> Oliver Neukum wrote:
> > +static int read_mac_addr(struct zd_chip *chip, u8 *mac_addr)
> > +{
> > +	static const zd_addr_t addr[2] = { CR_MAC_ADDR_P1, CR_MAC_ADDR_P2 };
> > +	return _read_mac_addr(chip, mac_addr, (const zd_addr_t *)addr);
> > +}
> > 
> > Why on the stack?
> 
> Technically it's not on the stack because it is static const (it goes in 
> rodata), but I don't think that this invalidates your point. What's the 
> alternative? kmalloc and kfree every time?

In this case rodata will work. However, if you ever switch to direct DMA
it will fail. I really did overlook the const keyword.

[..]
> > +static void disconnect(struct usb_interface *intf)
> > This is racy. It allows io to disconnected devices. You must take the
> > lock and set a flag that you test after you've taken the lock elsewhere.
> 
> Will fix, thanks.

You're welcome

	Regards
		Oliver
