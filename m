From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: brcm80211 breakage..
Date: Thu, 12 Jan 2012 08:08:50 +0100
Message-ID: <CACna6rzv6iFiGP5F2mMs+2wxh0rVpXcXyBjve2Nbn9Ybp8AFsg@mail.gmail.com>
References: <CA+55aFxw5e3EYCGYjkWiTmhy9-WaY4T_-MF7EYcn4jXuBoxAgw@mail.gmail.com>
	<4F0D6806.4080201@broadcom.com>
	<CA+55aFxzFKkUPSCU6Wr_FBPd6NFPeTctGR0kpqYJJ8fcw+ck7w@mail.gmail.com>
	<CA+55aFw7TdNzNi86cwF4o6xSWnbKuPS5CuhdbChzoboNw_1-Tw@mail.gmail.com>
	<4F0DC030.6090500@lwfinger.net>
	<CA+55aFyAX_OdE7yNp1vM1AmywrYZ9Pvr0EX47jNQciZKOQUQHg@mail.gmail.com>
	<4F0E3B7E.8040005@lwfinger.net>
	<CA+55aFyR9C8GjhKb8orr1kgd_G23=-mcmT-uz9zJd6wk7rYDPA@mail.gmail.com>
	<4F0E5E57.9060204@lwfinger.net>
	<CA+55aFw0XArx0jpNh4dWYFmvJbb+GJYAWRUN2Ec14oREiATo7g@mail.gmail.com>
	<CA+55aFxDOr_TT+kxp1SuwNFfm7KLTaWSLQwk1Fx8fWe7tdstcg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Arend van Spriel <arend@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:63044 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751752Ab2ALHIv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 02:08:51 -0500
Received: by wibhm14 with SMTP id hm14so966663wib.19
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2012 23:08:50 -0800 (PST)
In-Reply-To: <CA+55aFxDOr_TT+kxp1SuwNFfm7KLTaWSLQwk1Fx8fWe7tdstcg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/1/12 Linus Torvalds <torvalds@linux-foundation.org>:
> On Wed, Jan 11, 2012 at 9:20 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
>>
>> Maybe your BIOS firmware sets things up, and the Apple Macbook Air
>> doesn't? And the driver used to initialize things sufficiently, and
>> the changes have broken that?
>
> The code in v3.2 also used to support srom rev < 4, the new code
> doesn't seem to do that.

After hacking bcma to read SPROM from the correct location, what did
you get in dmesg? There should be info about version of SPROM.

There are 2 possible reasons for this issue:
1) bcma doesn't fully init your card
2) brcmsmac does sth wrong incorrectly as init

The story with brcmsmac is that it had code duplicated with bcma at
first. Now they partially switched to bcma, which inits bus for them,
and provide access to bus devices. However I'm afraid Broadcom didn't
remove duplicated init code (correct me if i'm wrong!). They may be
re-initializing bus and it's devices which cause some problems...

Linus: is this possible for you to give b43 a chance? It has to be comp=
iled with
B43_BCMA
B43_PHY_N
Unfortunately you have to install firmware manually to get b43 working
:( Howto is located at:
http://wireless.kernel.org/en/users/Drivers/b43
("Install b43-fwcutter" and "If you are using the b43 driver from 3.2
kernel or newer:").

b43 doesn't re-init bus devices, so this test will check if bcma is OK =
or not.

--=20
Rafa=C5=82
