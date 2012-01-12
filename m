From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: brcm80211 breakage..
Date: Thu, 12 Jan 2012 11:00:22 -0800
Message-ID: <CA+55aFx2UnVZP1Z44dMHeifB2nD1zJ87kz25zZjUdwv0ozwKPA@mail.gmail.com>
References: <CA+55aFxw5e3EYCGYjkWiTmhy9-WaY4T_-MF7EYcn4jXuBoxAgw@mail.gmail.com>
 <4F0D6806.4080201@broadcom.com> <CA+55aFxzFKkUPSCU6Wr_FBPd6NFPeTctGR0kpqYJJ8fcw+ck7w@mail.gmail.com>
 <CA+55aFw7TdNzNi86cwF4o6xSWnbKuPS5CuhdbChzoboNw_1-Tw@mail.gmail.com>
 <4F0DC030.6090500@lwfinger.net> <CA+55aFyAX_OdE7yNp1vM1AmywrYZ9Pvr0EX47jNQciZKOQUQHg@mail.gmail.com>
 <4F0E3B7E.8040005@lwfinger.net> <CA+55aFyR9C8GjhKb8orr1kgd_G23=-mcmT-uz9zJd6wk7rYDPA@mail.gmail.com>
 <4F0E5E57.9060204@lwfinger.net> <CA+55aFw0XArx0jpNh4dWYFmvJbb+GJYAWRUN2Ec14oREiATo7g@mail.gmail.com>
 <CA+55aFxDOr_TT+kxp1SuwNFfm7KLTaWSLQwk1Fx8fWe7tdstcg@mail.gmail.com> <CA+55aFzkCXnHfF_TO5M+gaN4RMvj_WNuW_QeBezuYBdWnwPDpg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	=?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Arend van Spriel <arend@broadcom.com>,
	Alwin Beukers <alwin@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:61500 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754560Ab2ALTAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 14:00:43 -0500
Received: by yhjj63 with SMTP id j63so1118503yhj.19
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2012 11:00:43 -0800 (PST)
In-Reply-To: <CA+55aFzkCXnHfF_TO5M+gaN4RMvj_WNuW_QeBezuYBdWnwPDpg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 11, 2012 at 11:13 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> All the BCMA changes make the revert somewhat non-trivial, could
> somebody who knows the code better please try to do it for me? It
> doesn't look complicated, and I can try to do it myself tomorrow if
> nobody else steps up, but I'd *really* prefer the guilty parties
> themselves to do it, ok?

Since I had the hardware to test, I could work on this and try to
figure out exactly what went wrong in that commit.

The problem seems to be simple: the SPROM contents *have* to be read
as aligned 16-bit words. Anything else seems to return 0xff and just
fails the transaction.

I didn't check all the combinations, of course, so who knows what the
exact details are, but it does look like the sprom has very limited
pci decode and simply refuses to touch anything but the one case it
can handle.

I'll send out a patch that seems to get things to a working state for
me. At least I have wireless connectivity again, I don't know if there
are some other problems remaining.

                      Linus
