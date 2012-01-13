From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [0/5] bcma/brcmsmac suspend/resume cleanups and fixes
Date: Fri, 13 Jan 2012 08:23:34 -0800
Message-ID: <CA+55aFx3eF3H2wmDiRVzOG9bcse7noZhHVLrRJ=w9=AotYFmLg@mail.gmail.com>
References: <CA+55aFzm21ZKs7e_ocVA1bQQ=Js2dJpbiycwHR3v8yNvb0MgTw@mail.gmail.com>
 <1326440480-26271-1-git-send-email-zajec5@gmail.com> <alpine.LNX.2.00.1201122354430.5860@air.linux-foundation.org>
 <4F101047.4090902@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Alwin Beukers <alwin@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:33374 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752730Ab2AMQX4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 11:23:56 -0500
Received: by wibhm14 with SMTP id hm14so509296wib.19
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2012 08:23:55 -0800 (PST)
In-Reply-To: <4F101047.4090902@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/1/13 Arend van Spriel <arend@broadcom.com>:
>
> I have a Dell Latitude E6410 over here. I applied the patches to
>
> commit 099469502f62fbe0d7e4f0b83a2f22538367f734
> Merge: 7c17d86 35f1526
> Author: Linus Torvalds <torvalds@linux-foundation.org>
> Date: =A0 Thu Jan 12 20:42:54 2012 -0800
>
> =A0 =A0Merge branch 'akpm' (aka "Andrew's patch-bomb, take two")
>
> Upon suspend my laptop hangs (see trace below pulled from serial
> console). I do not see the pr_debug in the suspend function (compiled
> with -DDEBUG). Unfortunately the same happens when I don't insert bcm=
a
> and brcmsmac. I attached the kernel configuration.

Ok, so it's not the bcma/brcmsmac drivers, and your hang seems to be
at suspend time.

There is at least one other suspend problem in the current merge
window, you may be hitting them. The one I know about is some oddity
with the machine check driver, so if you have CONFIG_X86_MCE enabled,
try compiling without it.

Also, try

    echo devices > /sys/power/pm_test
    echo mem > /sys/power/state

which doesn't do the "real" suspend, but only goes through the device
suspend. That often leaves more of a trace of what may have gone
wrong.

                         Linus
