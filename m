From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: brcm80211 breakage..
Date: Wed, 11 Jan 2012 17:06:15 -0800
Message-ID: <CA+55aFyAX_OdE7yNp1vM1AmywrYZ9Pvr0EX47jNQciZKOQUQHg@mail.gmail.com>
References: <CA+55aFxw5e3EYCGYjkWiTmhy9-WaY4T_-MF7EYcn4jXuBoxAgw@mail.gmail.com>
 <4F0D6806.4080201@broadcom.com> <CA+55aFxzFKkUPSCU6Wr_FBPd6NFPeTctGR0kpqYJJ8fcw+ck7w@mail.gmail.com>
 <CA+55aFw7TdNzNi86cwF4o6xSWnbKuPS5CuhdbChzoboNw_1-Tw@mail.gmail.com> <4F0DC030.6090500@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arend van Spriel <arend@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	=?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:34475 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751835Ab2ALBGh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2012 20:06:37 -0500
Received: by wibhm14 with SMTP id hm14so838560wib.19
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2012 17:06:36 -0800 (PST)
In-Reply-To: <4F0DC030.6090500@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 11, 2012 at 9:00 AM, Larry Finger <Larry.Finger@lwfinger.ne=
t> wrote:
> --- wireless-testing-new.orig/drivers/bcma/sprom.c
> +++ wireless-testing-new/drivers/bcma/sprom.c
> @@ -230,6 +230,7 @@ int bcma_sprom_get(struct bcma_bus *bus)
> =A0 =A0 =A0 =A0 * TODO: understand this condition and use it */
> =A0 =A0 =A0 =A0offset =3D (bus->chipinfo.id =3D=3D 0x4331) ? BCMA_CC_=
SPROM :
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BCMA_CC_SPROM_PCIE6;
> + =A0 =A0 =A0 pr_debug("SPROM offset 0x%x\n", offset);
> =A0 =A0 =A0 =A0bcma_sprom_read(bus, offset, sprom);
>
> =A0 =A0 =A0 =A0if (bus->chipinfo.id =3D=3D 0x4331)

So I did that - the offset is printed out as 0x0830
(BCMA_CC_SPROM_PCIE6). And when I change the offset to 0x0800
(BCMA_CC_SPROM), the complaint about SPROM version goes away.

IOW, these messages no longer exist:

[    0.815750] bcma: Unsupported SPROM revision: 255
[    0.815804] bcma: No SPROM available

but that doesn't actually make anything *work*. The brcms errors still
remain the same.

So the SPROM issue seems to be real, but irrelevant.

I also noticed that the CONFIG_BRCMDBG onyl enables pr_debug(), but
doesn't actually #define DEBUG, so pr_debug() gets compiled out
anyway.

I'll try with -DDEBUG in the brcm80211 subdirectory and see if I get
more interesting output that way.

                       Linus
