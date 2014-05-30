From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH v1 6/6] net: fec: Add software TSO support
Date: Fri, 30 May 2014 09:21:38 -0700
Message-ID: <1401466898.3645.127.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1401415552-2263-1-git-send-email-b38611@freescale.com>
	 <1401415552-2263-7-git-send-email-b38611@freescale.com>
	 <1401431422.3645.89.camel@edumazet-glaptop2.roam.corp.google.com>
	 <b5c16b8cd7874a8a979c3965984f768c@BLUPR03MB373.namprd03.prod.outlook.com>
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
Received: from mail-pb0-f53.google.com ([209.85.160.53]:54385 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933202AbaE3QVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 12:21:39 -0400
Received: by mail-pb0-f53.google.com with SMTP id md12so1887556pbc.12
        for <netdev@vger.kernel.org>; Fri, 30 May 2014 09:21:39 -0700 (PDT)
In-Reply-To: <b5c16b8cd7874a8a979c3965984f768c@BLUPR03MB373.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-05-30 at 07:16 +0000, fugang.duan@freescale.com wrote:

> Yes, test found it bounce all TX frames.
> Use 2 descriptors to transfer one part, which bring more complicate for driver. Of course, 
> Performance must be better.
> 

How cpu handles misaligned 32bit accesses ?

> Digression information:
> Imx6dl FEC HW have bandwidth issue limit to 400 ~ 700Mbps. Current performance with TSO is 506Mbps, cpu loading is about 40%.
> Later chips with FEC IP support byte alignment, such as imx6sx. On imx6sx FEC, no SW TSO, tx bandwidth is 840~870Mbps, cpu loading is 100%,
> After the software TSO, tx bandwidth is 840Mbps, cpu loading is 48%.

Since you have some cpu cycles, have you tried to always use the bounce
thing, using one descriptor per MSS, instead of two ?

(headers + payload)

This might help to get better bandwidth, by lowering overhead on DMA and
on NIC.
