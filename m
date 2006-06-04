From: "John Que" <qwejohn@gmail.com>
Subject: Re: [linux-usb-devel] [PATCH RFC] ZyDAS ZD1211 USB-WLAN driver
Date: Sun, 4 Jun 2006 19:29:38 +0300
Message-ID: <ada605fb0606040929p7a6ea69aw9488a75d611b23e5@mail.gmail.com>
References: <44817083.508@gentoo.org> <200606031951.09135.oliver@neukum.org>
	 <4481E497.2000505@gentoo.org> <200606040025.32275.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Daniel Drake" <dsd@gentoo.org>,
	linux-usb-devel@lists.sourceforge.net,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, "Ulrich Kunitz" <kune@deine-taler.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.239]:56973 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1750716AbWFDQ3j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Jun 2006 12:29:39 -0400
Received: by wr-out-0506.google.com with SMTP id 69so1227004wri
        for <netdev@vger.kernel.org>; Sun, 04 Jun 2006 09:29:38 -0700 (PDT)
To: "Oliver Neukum" <oliver@neukum.org>
In-Reply-To: <200606040025.32275.oliver@neukum.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I must confess I don't know much about the ZyDas driver and the rewrite
dirver, but folliowing this post  I looked a bit at the code (of both
zd1211 and the rewrite version) and I have a little question; this may
be
seen as a (little) off topic but I will be happy if somebody will
raise this coin.

  I had noticed that the zd1211 driver does call request_irq() in zd1205_open(),
file zd1205.c; grepping for request_irq() in the rewrite driver yields
no results.
(I looked at the rewrite version from a week ago but in this point it
is probably the
same).
Why is this so ? I assume that the softmac layer does not call request_irq() on
behalf of the driver because this is not supposed to be like it, as I understand
its functionality. Can anybody briefly calrify this point ?

Regards,
John


On 6/4/06, Oliver Neukum <oliver@neukum.org> wrote:
> Am Samstag, 3. Juni 2006 21:35 schrieb Daniel Drake:
> > Oliver Neukum wrote:
> > > +static int read_mac_addr(struct zd_chip *chip, u8 *mac_addr)
> > > +{
> > > +   static const zd_addr_t addr[2] = { CR_MAC_ADDR_P1, CR_MAC_ADDR_P2 };
> > > +   return _read_mac_addr(chip, mac_addr, (const zd_addr_t *)addr);
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
>
> [..]
> > > +static void disconnect(struct usb_interface *intf)
> > > This is racy. It allows io to disconnected devices. You must take the
> > > lock and set a flag that you test after you've taken the lock elsewhere.
> >
> > Will fix, thanks.
>
> You're welcome
>
>         Regards
>                 Oliver
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
