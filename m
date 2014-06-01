From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH v1 6/6] net: fec: Add software TSO support
Date: Sat, 31 May 2014 18:39:30 -0700
Message-ID: <1401586770.3645.139.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1401415552-2263-1-git-send-email-b38611@freescale.com>
	 <1401415552-2263-7-git-send-email-b38611@freescale.com>
	 <1401431422.3645.89.camel@edumazet-glaptop2.roam.corp.google.com>
	 <b5c16b8cd7874a8a979c3965984f768c@BLUPR03MB373.namprd03.prod.outlook.com>
	 <1401466898.3645.127.camel@edumazet-glaptop2.roam.corp.google.com>
	 <4961e71606b94f9d812f90dff0ed0ab1@BLUPR03MB373.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"ezequiel.garcia@free-electrons.com"
	<ezequiel.garcia@free-electrons.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:46117 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750793AbaFABjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 May 2014 21:39:33 -0400
Received: by mail-ie0-f177.google.com with SMTP id y20so3162837ier.36
        for <netdev@vger.kernel.org>; Sat, 31 May 2014 18:39:32 -0700 (PDT)
In-Reply-To: <4961e71606b94f9d812f90dff0ed0ab1@BLUPR03MB373.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-06-01 at 00:55 +0000, fugang.duan@freescale.com wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com> Data: Saturday, May 31, 2014 12:22 AM
> >
> >How cpu handles misaligned 32bit accesses ?
> 
> You mean use extra descriptor for misaligned bytes ? Or attach the misaligned bytes to header descriptor ?

I meant, maybe you could not force alignment of the IP/TCP headers on a
4byte boundary, but using +2 bytes offset

This way, frames would be 4-bytes aligned from the Etnernet Header.

> So I connect to APPLE MAC book to test again, test result (applied the patches to our internal kernel 3.10.31):
> High mem disable: tx bandwidth 942Mbps, cpu loading is 65%.
> High mem enable: tx bandwidth 930Mbps, cpu loading is 100%. 
> => I don't know why kernel highmem config enable cause so much performance drop ???
> 
> For your above suggestion "using one descriptor per MSS, instead of two":
> Yes, for imx6dl soc, we just do it like this.  For imx6sx soc FEC that support byte alignment,  so it also use one descriptor per MSS.
> 
> Thanks for your suggestion and response. Do you know why highmem cause much performance drop for SW TSO ?

Check NETIF_F_HIGHDMA : your driver might be able to advertise its
support.

Check your copies, because you might then need kmap()

For an example, read efx_skb_copy_bits_to_pio() in
drivers/net/ethernet/sfc/tx.c
