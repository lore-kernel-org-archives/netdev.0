From: "Haruki Dai-r35557" <Dai.Haruki@freescale.com>
Subject: RE: [PATCH] Gianfar SKB Recycling Support
Date: Wed, 17 May 2006 19:01:17 -0700
Message-ID: <18AEF66AFDF06F4CAAA1D419D000FD33524B99@az33exm24.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>,
	"Fleming Andy-afleming" <afleming@freescale.com>,
	"Kumar Gala" <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:47597 "EHLO
	de01egw02.freescale.net") by vger.kernel.org with ESMTP
	id S1750823AbWERCBY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 May 2006 22:01:24 -0400
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by de01egw02.freescale.net (8.12.11/de01egw02) with ESMTP id k4I2BWXm028874
	for <netdev@vger.kernel.org>; Wed, 17 May 2006 19:11:32 -0700 (MST)
Received: from az33exm24.fsl.freescale.net (az33exm24.am.freescale.net [10.64.32.14])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id k4I21NUa026662
	for <netdev@vger.kernel.org>; Wed, 17 May 2006 21:01:23 -0500 (CDT)
Content-class: urn:content-classes:message
To: "Andi Kleen" <ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Andi Kleen [mailto:ak@suse.de] 
> Sent: Wednesday, May 17, 2006 5:56 PM
> To: Haruki Dai-r35557
> Cc: netdev@vger.kernel.org; Fleming Andy-afleming; Kumar Gala
> Subject: Re: [PATCH] Gianfar SKB Recycling Support
> 
> On Thursday 18 May 2006 00:45, Haruki Dai-r35557 wrote:
> > This patch improves the IP forwarding throughput of
> > the Freescale TSEC/eTSEC Gianfar driver. By recycling
> > the Socket buffer and Data buffer, reduce the unnecessary
> > memory allocation and de-allocation in the forwarding
> > processing chain.
> 
> Seems very hackish because it only works inside the driver. 
> 
> Also  there is a reason why Linux doesn't support this normally - 
> it wrecks the unified memory management because you won't free
> your pools on memory pressure.
> 
> -Andi
>
With grant of the description, it looks negative in the memory management, but actually, the amount of memory usage in the driver layer is less than the ordinaly gianfar (around half), especially the NAPI is enable. This recycling is introduced in order to chop down the critical path memory usage.

Forwarding performance goes up 60 to 100% better, and amount of memory usage is half.

Thanks for comment,
Dai
