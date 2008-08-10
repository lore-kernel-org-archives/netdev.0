From: Brice Goglin <brice@myri.com>
Subject: Re: [PATCH 2/2] myri10ge: use ioremap_wc
Date: Sun, 10 Aug 2008 13:59:31 +0200
Message-ID: <489ED823.6000005@myri.com>
References: <488447E7.2060505@myri.com> <48844831.9040102@myri.com> <20080810112500.GA8060@deprecation.cyrius.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Martin Michlmayr <tbm@cyrius.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1798 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752906AbYHJMB5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Aug 2008 08:01:57 -0400
In-Reply-To: <20080810112500.GA8060@deprecation.cyrius.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Martin Michlmayr wrote:
> * Brice Goglin <brice@myri.com> [2008-07-21 10:26]:
>  =20
>> Switch to ioremap_wc(). We keep the MTRR code since ioremap_wc()
>> will use UC_MINUS when falling back to uncachable, and thus let
>> the MTRR WC take precedence.
>>    =20
>
> This change leads to a compilation failure on (at least) arm:
>
>   CC [M]  drivers/net/myri10ge/myri10ge.o
> drivers/net/myri10ge/myri10ge.c: In function =E2=80=98myri10ge_probe=E2=
=80=99:
> drivers/net/myri10ge/myri10ge.c:3725: error: implicit declaration of =
function =E2=80=98ioremap_wc=E2=80=99
> drivers/net/myri10ge/myri10ge.c:3725: warning: assignment makes point=
er from integer without a cast
> make[3]: *** [drivers/net/myri10ge/myri10ge.o] Error 1
>  =20


Isn't arm's asm/io.h supposed to get
#ifndef ARCH_HAS_IOREMAP_WC
#define ioremap_wc ioremap_nocache
#endif
from asm-generic/iomap.h since ARCH_HAS_IOREMAP_WC isn't defined on arm=
 ?

Brice

