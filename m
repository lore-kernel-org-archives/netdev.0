From: Daniel Drake <dsd@gentoo.org>
Subject: Re: [linux-usb-devel] [PATCH RFC] ZyDAS ZD1211 USB-WLAN driver
Date: Sat, 03 Jun 2006 20:35:51 +0100
Message-ID: <4481E497.2000505@gentoo.org>
References: <44817083.508@gentoo.org> <200606031951.09135.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-usb-devel@lists.sourceforge.net,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, Ulrich Kunitz <kune@deine-taler.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta08-winn.ispmail.ntl.com ([81.103.221.48]:49418 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1751796AbWFCTfd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Jun 2006 15:35:33 -0400
To: Oliver Neukum <oliver@neukum.org>
In-Reply-To: <200606031951.09135.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oliver Neukum wrote:
> +static int read_mac_addr(struct zd_chip *chip, u8 *mac_addr)
> +{
> +	static const zd_addr_t addr[2] = { CR_MAC_ADDR_P1, CR_MAC_ADDR_P2 };
> +	return _read_mac_addr(chip, mac_addr, (const zd_addr_t *)addr);
> +}
> 
> Why on the stack?

Technically it's not on the stack because it is static const (it goes in 
rodata), but I don't think that this invalidates your point. What's the 
alternative? kmalloc and kfree every time?

(Just seems a little over the top for such a small array)

> +static int zd1211_hw_reset_phy(struct zd_chip *chip)
> +{
> +	static const struct zd_ioreq16 ioreqs[] = {
> 
> This is too much to allocate on the stack.

Again static const, it's definately in rodata, checked with objdump. Do 
we need to change this?

> +static void disconnect(struct usb_interface *intf)
> This is racy. It allows io to disconnected devices. You must take the
> lock and set a flag that you test after you've taken the lock elsewhere.

Will fix, thanks.

Daniel

