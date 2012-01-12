From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: brcm80211 breakage..
Date: Wed, 11 Jan 2012 21:30:05 -0800
Message-ID: <CA+55aFxDOr_TT+kxp1SuwNFfm7KLTaWSLQwk1Fx8fWe7tdstcg@mail.gmail.com>
References: <CA+55aFxw5e3EYCGYjkWiTmhy9-WaY4T_-MF7EYcn4jXuBoxAgw@mail.gmail.com>
 <4F0D6806.4080201@broadcom.com> <CA+55aFxzFKkUPSCU6Wr_FBPd6NFPeTctGR0kpqYJJ8fcw+ck7w@mail.gmail.com>
 <CA+55aFw7TdNzNi86cwF4o6xSWnbKuPS5CuhdbChzoboNw_1-Tw@mail.gmail.com>
 <4F0DC030.6090500@lwfinger.net> <CA+55aFyAX_OdE7yNp1vM1AmywrYZ9Pvr0EX47jNQciZKOQUQHg@mail.gmail.com>
 <4F0E3B7E.8040005@lwfinger.net> <CA+55aFyR9C8GjhKb8orr1kgd_G23=-mcmT-uz9zJd6wk7rYDPA@mail.gmail.com>
 <4F0E5E57.9060204@lwfinger.net> <CA+55aFw0XArx0jpNh4dWYFmvJbb+GJYAWRUN2Ec14oREiATo7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Arend van Spriel <arend@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	=?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:56714 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951Ab2ALFa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 00:30:27 -0500
Received: by wibhm14 with SMTP id hm14so930957wib.19
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2012 21:30:26 -0800 (PST)
In-Reply-To: <CA+55aFw0XArx0jpNh4dWYFmvJbb+GJYAWRUN2Ec14oREiATo7g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 11, 2012 at 9:20 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Maybe your BIOS firmware sets things up, and the Apple Macbook Air
> doesn't? And the driver used to initialize things sufficiently, and
> the changes have broken that?

The code in v3.2 also used to support srom rev < 4, the new code
doesn't seem to do that.

Looking at the older initvars_srom_pci() (now "srom_var_init()") the
old code started out reading just SROM_WORDS, and then reading more
only if it found the srom4 signature. The new code always reads
SROM4_WORDS.

I dunno. But it looks to me like the new driver has dropped some logic
that used to exist in that driver. I don't know if it was ever used,
though, nor do I know if it's relevant. But if tat "dropped some
logic" is more widespread, it might well also cover some
initialization code.

                        Linus
