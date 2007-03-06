From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] div64_64 support
Date: Tue, 06 Mar 2007 13:58:34 -0800 (PST)
Message-ID: <20070306.135834.26100913.davem@davemloft.net>
References: <20070306144529.GA2004@one.firstfloor.org>
	<84C47260-4B57-4568-8197-58F438A6F737@e18.physik.tu-muenchen.de>
	<20070306102941.32471d57@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rkuhn@e18.physik.tu-muenchen.de, andi@firstfloor.org,
	dada1@cosmosbay.com, jengelh@linux01.gwdg.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55341
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030327AbXCFV6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 16:58:37 -0500
In-Reply-To: <20070306102941.32471d57@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Tue, 6 Mar 2007 10:29:41 -0800

> /* calculate the cubic root of x using Newton-Raphson */
> static uint32_t ncubic(uint64_t a)
> {
> 	uint64_t x;
> 
> 	/* Initial estimate is based on:
> 	 * cbrt(x) = exp(log(x) / 3)
> 	 */
> 	x = 1u << (fls64(a)/3);
> 
> 	/* Converges in 3 iterations to > 32 bits */
> 
> 	x = (2 * x + div64_64(a, x*x)) / 3;
> 	x = (2 * x + div64_64(a, x*x)) / 3;
> 	x = (2 * x + div64_64(a, x*x)) / 3;
> 
> 	return x;
> }

Indeed that will be the fastest variant for cpus with hw
integer division.

I did a quick sparc64 port, here is what I got:

Function     clocks  mean(us) max(us)  std(us)  total error
ocubic          529     0.35    15.16     0.66 545101
ncubic          498     0.33    12.83     0.36 576263
acbrt           427     0.28    11.04     0.33 547562
hcbrt           393     0.26    10.18     0.47 2410
