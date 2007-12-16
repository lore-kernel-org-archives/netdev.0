From: Jouni Malinen <j@w1.fi>
Subject: Re: [PATCH] PS3: gelic: Add wireless support for PS3
Date: Sun, 16 Dec 2007 15:42:28 -0800
Message-ID: <20071216234228.GQ5698@jm.kir.nu>
References: <20071213211626.BF8E.MOKUNO@sm.sony.co.jp> <1197580418.14270.6.camel@localhost.localdomain> <20071214134918.275E.MOKUNO@sm.sony.co.jp> <1197637127.16724.1.camel@localhost.localdomain> <20071215014244.GI5698@jm.kir.nu> <1197827354.6358.2.camel@localhost.localdomain> <20071216181159.GP5698@jm.kir.nu> <1197846610.7302.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Masakazu Mokuno <mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	geoffrey.levand-mEdOJwZ7QcZBDgjK7y7TUQ@public.gmane.org,
	Geert Uytterhoeven <Geert.Uytterhoeven-osDt5Q4Chk1BDgjK7y7TUQ@public.gmane.org>
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1197846610.7302.1.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 16, 2007 at 06:10:10PM -0500, Dan Williams wrote:
> On Sun, 2007-12-16 at 10:11 -0800, Jouni Malinen wrote:
> > It is a new key type regardless of whether it is PSK or passphrase. The
> > current key types (IW_AUTH_CIPHER_*) are WEP40, TKIP, CCMP, and WEP104..

> Ah, it's a different key because it's not set _during_ the 4-way
> handshake, but just sent to the fw directly and the fw handles it,
> right?

There are two cases here, but in both of them, them PMK (i.e., PSK for
WPA-Personal) needs to be set just before the 4-way handshake would
start. When using WPA-Personal, the PSK would be set just before (or as
part of) association request. When using WPA-Enterprise (WPA-EAP), the
PMK would be set after having completed IEEE 802.1X/EAP authentication
(and the driver/firmware would then take care of 4-way handshake). Both
cases will end up disabling the user space supplicant from taking part
in 4-way handshake, i.e., it will ignore EAPOL-Key frames should they be
delivered through the netdev and expects the driver/firmware to process
them.

-- 
Jouni Malinen                                            PGP id EFC895FA
