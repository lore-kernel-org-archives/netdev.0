From: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH 12/14] [rndis_host] Add RNDIS physical medium checking into generic_rndis_bind()
Date: Sun, 27 Jan 2008 08:29:53 -0800
Message-ID: <200801270829.53470.david-b@pacbell.net>
References: <20080125225032.11716.77713.stgit@fate.lan> <20080125225139.11716.91641.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bjd-a1rhEgazXTw@public.gmane.org
To: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080125225139.11716.91641.stgit-q/85JClnwdg@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 25 January 2008, Jussi Kivilinna wrote:
> +=A0=A0=A0=A0=A0=A0=A0if(flags & FLAG_RNDIS_PHYM_WIRELESS &&
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
*phym !=3D RNDIS_PHYSICAL_MEDIUM_WIRELESS_LAN) {
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0dev_err(&intf->dev, "dr=
iver requires wireless physical "
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0"medium, but device is =
not.\n");
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0retval =3D -ENODEV;
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0goto halt_fail_and_rele=
ase;
> +=A0=A0=A0=A0=A0=A0=A0}
> +=A0=A0=A0=A0=A0=A0=A0if(flags & FLAG_RNDIS_PHYM_NOT_WIRELESS &&
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
*phym =3D=3D RNDIS_PHYSICAL_MEDIUM_WIRELESS_LAN) {
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0dev_err(&intf->dev, "dr=
iver requires non-wireless physical "
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0"medium, but device is =
wireless.\n");
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0retval =3D -ENODEV;

Well, other than the obvious checkpatch.pl warnings waiting to trigger
("if" is not a function; put a space before the paren) and what I'd cal=
l
missing parens around the "flags & ...", those are *not* errors.  No
wonder you thought this would cause too many messages!!

Just make those be dev_dbg() calls instead.  The strongest message leve=
l
you can argue for there would be KERN_NOTICE, "normal but significant";
except it's not especially significant.  Filtering by netif_msg_probe()
may be a good idea too; that's normally enabled in this framework.

- Dave

p.s. Before these get submitted, *all* of them need to pass "checkpatch=
=2Epl".
  Ideally, "checkpatch.pl --strict" ...
