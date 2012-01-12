From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: brcm80211 breakage..
Date: Wed, 11 Jan 2012 18:11:46 -0800
Message-ID: <CA+55aFyR9C8GjhKb8orr1kgd_G23=-mcmT-uz9zJd6wk7rYDPA@mail.gmail.com>
References: <CA+55aFxw5e3EYCGYjkWiTmhy9-WaY4T_-MF7EYcn4jXuBoxAgw@mail.gmail.com>
 <4F0D6806.4080201@broadcom.com> <CA+55aFxzFKkUPSCU6Wr_FBPd6NFPeTctGR0kpqYJJ8fcw+ck7w@mail.gmail.com>
 <CA+55aFw7TdNzNi86cwF4o6xSWnbKuPS5CuhdbChzoboNw_1-Tw@mail.gmail.com>
 <4F0DC030.6090500@lwfinger.net> <CA+55aFyAX_OdE7yNp1vM1AmywrYZ9Pvr0EX47jNQciZKOQUQHg@mail.gmail.com>
 <4F0E3B7E.8040005@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Arend van Spriel <arend@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	=?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47267 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752102Ab2ALCMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2012 21:12:08 -0500
Received: by wgbds12 with SMTP id ds12so1248502wgb.1
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2012 18:12:07 -0800 (PST)
In-Reply-To: <4F0E3B7E.8040005@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 11, 2012 at 5:46 PM, Larry Finger <Larry.Finger@lwfinger.net> wrote:
>
> OK. The SPROM issue is not completely irrelevant as that has to be correct,
> but obviously not sufficient.

Hmm. Having dug a bit deeper, I do think it's kind of related.

I get -ENODATA form sprom_read_pci(), but that function actually seems
to get the offset *right*.

Some printout shows that for that chip, I have

 - ai_get_ccrev(sih) = 34
 - sprom_offset = 0x800

but then it apparently reads all ones anyway. At least in the first
word. So then I get that -ENODATA error.

So once more, it's somehow related to the sprom, just in a new place:
sprom_read_pci() in brcmsmac/srom.c instead of drivers/bcma/sprom.c.

Does that give people any new ideas to try out?

                      Linus
