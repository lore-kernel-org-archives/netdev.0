From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH v1 4/6] net: fec: Increase buffer descriptor entry number
Date: Fri, 30 May 2014 08:40:57 -0700
Message-ID: <1401464457.3645.109.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1401415552-2263-1-git-send-email-b38611@freescale.com>
	 <1401415552-2263-5-git-send-email-b38611@freescale.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1725053E@AcuExch.aculab.com>
	 <bf938381e86b4ef5b4e3cbec8733fd2e@BLUPR03MB373.namprd03.prod.outlook.com>
	 <1401455586.3645.96.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140530140137.GC783@arch.cereza>
	 <1401461642.3645.104.camel@edumazet-glaptop2.roam.corp.google.com>
	 <417d6b6ae192430f9fee0a339074d9c6@BLUPR03MB373.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "ezequiel.garcia@free-electrons.com"
	<ezequiel.garcia@free-electrons.com>,
	David Laight <David.Laight@ACULAB.COM>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:55712 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932126AbaE3Pk7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 11:40:59 -0400
Received: by mail-pb0-f49.google.com with SMTP id jt11so1847213pbb.22
        for <netdev@vger.kernel.org>; Fri, 30 May 2014 08:40:59 -0700 (PDT)
In-Reply-To: <417d6b6ae192430f9fee0a339074d9c6@BLUPR03MB373.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-05-30 at 15:08 +0000, fugang.duan@freescale.com wrote:

> If frag page data is not match the alignment for ethernet DMA controller, there need three descriptor for one MSS:
> One descriptor for headers, one for the first non-align bytes copied from frag page, one for the rest of frag page.
> 

You could avoid the 2nd descriptor, by copying the unaligned part of the
payload into first descriptor (containing headers : about 66 bytes or so
you have room, if not, increase the 128 bytes room to 192 bytes)

> So one frame may cost descriptor number is: 3 x 45 

May... but in general it would be closer of 2 * 45


> 
> So the descriptors slots set to 512 is not big, just is reasonable. Do you think ?

I believe it is fine : that is about 5 64KB TSO packets.
