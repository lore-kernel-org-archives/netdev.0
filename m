From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: brcm80211 breakage..
Date: Thu, 12 Jan 2012 23:13:00 -0800
Message-ID: <CA+55aFyo=A7YceX11_Tuc_-7Ube_EYp1a2iSb7sFBN0Dc_x=zQ@mail.gmail.com>
References: <CA+55aFxw5e3EYCGYjkWiTmhy9-WaY4T_-MF7EYcn4jXuBoxAgw@mail.gmail.com>
 <4F0D6806.4080201@broadcom.com> <CA+55aFxzFKkUPSCU6Wr_FBPd6NFPeTctGR0kpqYJJ8fcw+ck7w@mail.gmail.com>
 <CA+55aFw7TdNzNi86cwF4o6xSWnbKuPS5CuhdbChzoboNw_1-Tw@mail.gmail.com>
 <4F0DC030.6090500@lwfinger.net> <CA+55aFyAX_OdE7yNp1vM1AmywrYZ9Pvr0EX47jNQciZKOQUQHg@mail.gmail.com>
 <4F0E3B7E.8040005@lwfinger.net> <CA+55aFyR9C8GjhKb8orr1kgd_G23=-mcmT-uz9zJd6wk7rYDPA@mail.gmail.com>
 <4F0E5E57.9060204@lwfinger.net> <CA+55aFw0XArx0jpNh4dWYFmvJbb+GJYAWRUN2Ec14oREiATo7g@mail.gmail.com>
 <CA+55aFxDOr_TT+kxp1SuwNFfm7KLTaWSLQwk1Fx8fWe7tdstcg@mail.gmail.com>
 <CA+55aFzkCXnHfF_TO5M+gaN4RMvj_WNuW_QeBezuYBdWnwPDpg@mail.gmail.com>
 <CA+55aFx2UnVZP1Z44dMHeifB2nD1zJ87kz25zZjUdwv0ozwKPA@mail.gmail.com>
 <CA+55aFzNJbM=ohXninJ06518e3a6E8vySg8GT6dx+Qovk1QW0Q@mail.gmail.com>
 <4F0F3DEC.4050605@broadcom.com> <CA+55aFw==r4TF5WPn5Ggz32m7yi2T71Ghdx+7ME=pEjQLqU=uw@mail.gmail.com>
 <CA+55aFxMh0T1W06YHepcPAyemcR4rrxghQeRKsW3MtT+gNK9eg@mail.gmail.com>
 <CACna6rwVTN6jQuAjVFN0p8QRVpt89ne7LxKbcmoorbZFtxFLkQ@mail.gmail.com>
 <CA+55aFz8z9V5vxBMAH3TFVmROj0C-8Mb+G0Ki=Yuai5_KG893A@mail.gmail.com>
 <CACna6rzeTmQu0c1=f6gizG_=XRkt3FdB7c_sAJtktjLdFmTQ3g@mail.gmail.com>
 <CA+55aFxZ7H=x2-rgQgRE9b=ky-h0WM1x-48Zs8a0dVt0NvkB_g@mail.gmail.com>
 <CA+55aFzP2NfDqiG9NCP+SyXstuNzJAVpN=KXTirhjhYzaCyPjA@mail.gmail.com>
 <CA+55aFx4Xuai3wS1Jk09mNeO7gVYqzTyX5ev_9oRxCyNdBrEaw@mail.gmail.com> <CACna6rwuyp+VY3ZveCv+HLuyfu0X27pxKAc=rdzrvY2BJPk8QQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arend van Spriel <arend@broadcom.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Alwin Beukers <alwin@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: =?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:35626 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751882Ab2AMHNo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 02:13:44 -0500
Received: by ghbg16 with SMTP id g16so746946ghb.19
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2012 23:13:43 -0800 (PST)
In-Reply-To: <CACna6rwuyp+VY3ZveCv+HLuyfu0X27pxKAc=rdzrvY2BJPk8QQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/1/12 Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>:
>
> Linus: can you do one trivial test for me? Please simply try unloadin=
g
> bcma before suspending. Then resume and load bcma and brcmsmac. Does
> it still lockup your machine?

That works, but is not interesting. It just reloads everything.

The thing is, your hardware clearly never powers anything down,
because the bcma suspend/resume functions aren't hooked up to
anything, so the brcmsmac suspend/resume never gets called at all.

And it sounds like it works for you for the simple reason that your
hardware never loses power - so you don't need to do anything for
suspend/resume.

But there is absolutely zero question about it - the code does not
work. Never has. It's just that your hardware doesn't *need* any code
at all, and as far as you are concerned, suspend/resume doesn't even
really happen (the PCI layer handles the regular "set to D3 and back
to D0", so the fact that the driver doesn't do anything never shows
up)

                       Linus
