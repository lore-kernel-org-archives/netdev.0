From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: brcm80211 breakage..
Date: Thu, 12 Jan 2012 21:34:22 -0800
Message-ID: <CA+55aFx4Xuai3wS1Jk09mNeO7gVYqzTyX5ev_9oRxCyNdBrEaw@mail.gmail.com>
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
 <CA+55aFxZ7H=x2-rgQgRE9b=ky-h0WM1x-48Zs8a0dVt0NvkB_g@mail.gmail.com> <CA+55aFzP2NfDqiG9NCP+SyXstuNzJAVpN=KXTirhjhYzaCyPjA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Alwin Beukers <alwin@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: =?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>,
	Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:36909 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759Ab2AMFen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 00:34:43 -0500
Received: by ggdk6 with SMTP id k6so1447291ggd.19
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2012 21:34:43 -0800 (PST)
In-Reply-To: <CA+55aFzP2NfDqiG9NCP+SyXstuNzJAVpN=KXTirhjhYzaCyPjA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/1/12 Linus Torvalds <torvalds@linux-foundation.org>:
> 2012/1/12 Linus Torvalds <torvalds@linux-foundation.org>:
>>
>> I'm surprised it has ever worked for anybody. It certainly doesn't work for me.
>
> So I can suspend the bcma driver on its own until the cows come home.
>
> But after I have suspended the bcma driver even once, just doing a
> "modprobe brcmsmac" will hang the machine hard. Dunno where, but this
> is probably the same thing as "hangs on resume".

Guys, has suspend/resume with the bcma interface been tested AT ALL?

The suspend/resume fields of "struct bcma_driver" are COMPLETELY
UNUSED. The only place in the kernel that uses them is the brcmsmac
driver that does this write-only assignment:

        .suspend  = brcms_suspend,
        .resume   = brcms_resume,

nothing else uses them. NOTHING. I tested by just removing the fields
and compiling the bcma subsystem, just in case there was something
really subtle that I was missing and was hidden through some magic
hidden approach. But no.

Seriously - how was something that isn't even connected ever supposed
to work at all? And why was the BCMA conversion of that driver sent
up-stream if something as fundamental as suspend/resume had never been
done, and didn't actually work?

What am I missing now? How the hell can this ever have worked for
ANYBODY? What kind of f*&*ing sick joke is this all?

                      Linus
