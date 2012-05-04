From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCHv3 6/6] mISDN: Help to identify the card
Date: Fri, 4 May 2012 10:48:26 -0400
Message-ID: <CAP=VYLpKjFHx7b3oTjz7a8wvxQmPME-sK147n8CX6y8+Pii2rg@mail.gmail.com>
References: <1336140935-25830-1-git-send-email-kkeil@linux-pingi.de> <1336140935-25830-7-git-send-email-kkeil@linux-pingi.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Karsten Keil <isdn@linux-pingi.de>
To: Karsten Keil <kkeil@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:54878 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752866Ab2EDOs6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2012 10:48:58 -0400
Received: by lahj13 with SMTP id j13so2063233lah.19
        for <netdev@vger.kernel.org>; Fri, 04 May 2012 07:48:56 -0700 (PDT)
In-Reply-To: <1336140935-25830-7-git-send-email-kkeil@linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 4, 2012 at 10:15 AM, Karsten Keil <kkeil@linux-pingi.de> wr=
ote:
> From: Karsten Keil <isdn@linux-pingi.de>
>
> With multiple cards is hard to figure out which port caused trouble
> int the layer2 routines (e.g. got a timeout).
> Now we have the informations in the log output.

If you are in here changing all these printk(KERN_LEVEL ...) lines anyw=
ay,
then perhaps it is a good time to make use of pr_warn() and friends to
help avoid some multi-line fragmentation things like this:

> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk=
(KERN_WARNING
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 "%s: windowar[%d] is NULL\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0__func__, p1);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0mISDNDevName4ch(&l2->ch), p1);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0l2->windowar[p1] =3D N=
ULL;

Paul.
