From: "Toshiharu Okada" <toshiharu-linux@dsn.okisemi.com>
Subject: Re: Bad initialisers in pch_gbe_param.c:pch_gbe_check_options ?
Date: Mon, 22 Nov 2010 12:20:32 +0900
Message-ID: <008001cb89f4$79dd4180$66f8800a@maildom.okisemi.com>
References: <20101121171710.GA1682@gallifrey>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: "Dr. David Alan Gilbert" <linux@treblig.org>,
	<masa-korg@dsn.okisemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:33794 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756547Ab0KVDWX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Nov 2010 22:22:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave

Thank you for the pointing out.
This driver's author was changed to me from "Masayuki Ohtake".

So, I confirmed your pointing out and understood the issue.
I will modified and submit the patch.

Best regards
Toshiharu Okada (OKI SEMICONDUCTOR)
-----
Date: Sun, 21 Nov 2010 17:17:10 +0000
From: "Dr. David Alan Gilbert" <linux@treblig.org>
> Hi,
>   The 'sparse' checker pointed me at the following code in pch_gbe_param.c
> that does look wrong:
>
> drivers/net/pch_gbe/pch_gbe_param.c:437:26: warning: Initializer entry
defined twice
> drivers/net/pch_gbe/pch_gbe_param.c:438:26:   also defined here
>
>                 static const struct pch_gbe_option opt = {
>                         .type = range_option,
>                         .name = "Transmit Descriptors",
>                         .err  = "using default of "
>                                 __MODULE_STRING(PCH_GBE_DEFAULT_TXD),
>                         .def  = PCH_GBE_DEFAULT_TXD,
>    *******              .arg  = { .r = { .min = PCH_GBE_MIN_TXD } },
>    *******              .arg  = { .r = { .max = PCH_GBE_MAX_TXD } }
>                 };
>
> The structure has a union called arg inside of which are two structs (l
and r)
> and r has two members, min and max.  This initialiser is initialising the
whole
> of .arg twice; I wrote a little test stand alone program and indeed
> when doing it this way 'min' ended up as zero.
>
> I suggest what you really want is:
>                 static const struct pch_gbe_option opt = {
>                         .type = range_option,
>                         .name = "Transmit Descriptors",
>                         .err  = "using default of "
>                                 __MODULE_STRING(PCH_GBE_DEFAULT_TXD),
>                         .def  = PCH_GBE_DEFAULT_TXD,
>                         .arg  = { .r = { .min = PCH_GBE_MIN_TXD,
>                                          .max = PCH_GBE_MAX_TXD } }
>                 };
>
> (There's also an equivalent pair a few lines below)
>
> drivers/net/pch_gbe/pch_gbe_param.c:453:26: warning: Initializer entry
defined twice
> drivers/net/pch_gbe/pch_gbe_param.c:454:26:   also defined here
>
> Dave
> -- 
>  -----Open up your eyes, open up your mind, open up your code ------- 
> / Dr. David Alan Gilbert    |       Running GNU/Linux       | Happy  \
> \ gro.gilbert @ treblig.org |                               | In Hex /
>  \ _________________________|_____ http://www.treblig.org   |_______/
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

