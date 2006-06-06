From: David Brownell <david-b@pacbell.net>
Subject: Re: [linux-usb-devel] [PATCH RFC] ZyDAS ZD1211 USB-WLAN driver
Date: Mon, 5 Jun 2006 22:41:02 -0700
Message-ID: <200606052241.03845.david-b@pacbell.net>
References: <44817083.508@gentoo.org> <4481E497.2000505@gentoo.org> <200606040025.32275.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Oliver Neukum <oliver@neukum.org>, Daniel Drake <dsd@gentoo.org>,
	netdev@vger.kernel.org, Ulrich Kunitz <kune@deine-taler.de>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp107.sbc.mail.mud.yahoo.com ([68.142.198.206]:20333 "HELO
	smtp107.sbc.mail.mud.yahoo.com") by vger.kernel.org with SMTP
	id S932116AbWFFFlG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jun 2006 01:41:06 -0400
To: linux-usb-devel@lists.sourceforge.net
In-Reply-To: <200606040025.32275.oliver@neukum.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 03 June 2006 3:25 pm, Oliver Neukum wrote:
> Am Samstag, 3. Juni 2006 21:35 schrieb Daniel Drake:
> > Oliver Neukum wrote:
> > > +static int read_mac_addr(struct zd_chip *chip, u8 *mac_addr)
> > > +{
> > > +	static const zd_addr_t addr[2] = { CR_MAC_ADDR_P1, CR_MAC_ADDR_P2 };
> > > +	return _read_mac_addr(chip, mac_addr, (const zd_addr_t *)addr);
> > > +}
> > > 
> > > Why on the stack?
> > 
> > Technically it's not on the stack because it is static const (it goes in 
> > rodata), but I don't think that this invalidates your point. What's the 
> > alternative? kmalloc and kfree every time?
> 
> In this case rodata will work. However, if you ever switch to direct DMA
> it will fail. I really did overlook the const keyword.

On some platforms rodata will work; but it's not guaranteed on any.
See Documentation/DMA-mapping.txt and read the little section at the
top explaining what types of memory can be DMA'd from ... neither stack,
nor BSS, nor data, nor rodata, nor text are OK.

- Dave
