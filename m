From: Jouni Malinen <j@w1.fi>
Subject: Re: [PATCH] PS3: gelic: Add wireless support for PS3
Date: Fri, 14 Dec 2007 17:42:44 -0800
Message-ID: <20071215014244.GI5698@jm.kir.nu>
References: <20071213211626.BF8E.MOKUNO@sm.sony.co.jp> <1197580418.14270.6.camel@localhost.localdomain> <20071214134918.275E.MOKUNO@sm.sony.co.jp> <1197637127.16724.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Masakazu Mokuno <mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	geoffrey.levand-mEdOJwZ7QcZBDgjK7y7TUQ@public.gmane.org,
	Geert Uytterhoeven <Geert.Uytterhoeven-osDt5Q4Chk1BDgjK7y7TUQ@public.gmane.org>
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1197637127.16724.1.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 14, 2007 at 07:58:47AM -0500, Dan Williams wrote:
> On Fri, 2007-12-14 at 14:03 +0900, Masakazu Mokuno wrote:
> > The PS3 wireless device does the association and 4way handshake in its
> > firmware/hypervisor.  No interventions between them are allowed to the guest
> > OSes.  

> That sort of sucks; but I guess there's not too much you can do about
> it.  That probably means that using wpa_supplicant + WPA is completely
> out of the picture, which unfortunately makes the PS3 wireless unlike
> any other card, which would require special-casing the PS3 in userspace
> tools.

The current wpa_supplicant development branch (0.6.x) supports drivers
that want to do 4-way handshake in the driver/firmware (e.g., OSX,
iPhone, this PS3 driver). In case of WPA-PSK, this doesn't really mean
more than just passing through the passphrase/PSK to the association
routine, but still, this allows the driver to be configured through
wpa_supplicant, if desired.

However, there is a part that you are not going to like.. This is likely
using a private ioctl for some parts of the association requests, i.e.,
no -Dwext.. I would assume that this could be cleaned up, though, if
WEXT would be extended a bit to allow one more enc_capa to notify
whether the driver wants to take care of 4-way handshake and to allow
the PSK to be configured with a new key type.


PS.

It would be interesting to see whether the driver/firmware/hypervisor
could be convinced to allow EAPOL frames to go through between
association and 4-way handshake (which would be completed by
driver/firmware). This is the way I can support WPA/WPA2-Enterprise with
OSX..

-- 
Jouni Malinen                                            PGP id EFC895FA
