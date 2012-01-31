From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: brcm80211 breakage..
Date: Tue, 31 Jan 2012 09:02:38 -0800
Message-ID: <CA+55aFy5-x6Zevga=rX_q+6vsmXFHyMJ+m8YqrqjC6yELqS6mw@mail.gmail.com>
References: <CA+55aFx2UnVZP1Z44dMHeifB2nD1zJ87kz25zZjUdwv0ozwKPA@mail.gmail.com>
 <20120131120846.GA8799@polaris.bitmath.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville@redhat.com>,
	Network Development <netdev@vger.kernel.org>,
	=?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>
To: Henrik Rydberg <rydberg@euromail.se>,
	Arend van Spriel <arend@broadcom.com>,
	Franky Lin <frankyl@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:65399 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752479Ab2AaRC7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 12:02:59 -0500
Received: by ghrr11 with SMTP id r11so147523ghr.19
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2012 09:02:59 -0800 (PST)
In-Reply-To: <20120131120846.GA8799@polaris.bitmath.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 31, 2012 at 4:08 AM, Henrik Rydberg <rydberg@euromail.se> w=
rote:
>
> probing simply fails on my machine,
>
> [  882.064120] bcma: Failed to get SPROM: -71
> [ =A0882.064256] bcma-pci-bridge: probe of 0000:01:00.0 failed with e=
rror -2
>
> resulting in no wireless. Since the bcma SPROM setup allegedly is
> unused, simply ignoring the error with this hack

I personally hit the "No SPROM available" case, which is apparently
why it works for me.

That said, I obviously agree with your patch: if we don't fail for the
"No SPROM available" case, then we damn well shouldn't fail just
because it *is* available but we can't read it or whatever.

So Ack on the patch from me, but it should go through the network
guys. Arend, John?

                         Linus

> diff --git a/drivers/bcma/main.c b/drivers/bcma/main.c
> index febbc0a..cb69fb0 100644
> --- a/drivers/bcma/main.c
> +++ b/drivers/bcma/main.c
> @@ -171,7 +171,6 @@ int bcma_bus_register(struct bcma_bus *bus)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pr_err("No SPROM available\n");
> =A0 =A0 =A0 =A0} else if (err) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pr_err("Failed to get SPROM: %d\n", er=
r);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOENT;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0/* Register found cores */
