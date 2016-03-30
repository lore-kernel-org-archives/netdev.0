From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC] net: mvneta: 64bit platform support
Date: Wed, 30 Mar 2016 15:55:52 +0200
Message-ID: <5610664.hi4FO8Jfup@wuerfel>
References: <20160330213700.41876e09@xhacker> <20160330214535.4139ebe5@xhacker>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Jisheng Zhang <jszhang@marvell.com>,
	thomas.petazzoni@free-electrons.com, davem@davemloft.net,
	netdev@vger.kernel.org, gregory.clement@free-electrons.com,
	mw@semihalf.com
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.10]:58704 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751217AbcC3N4c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 09:56:32 -0400
In-Reply-To: <20160330214535.4139ebe5@xhacker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 30 March 2016 21:45:35 Jisheng Zhang wrote:
> oh, missing some code:
> #ifdef CONFIG_64BIT
> data = ((u64)rx_desc->reserved5 << 32) | rx_desc->buf_cookie;
> #else
> data = (void*)rx_desc->buf_cookie;
> #endif
> 
> 

Please use the upper_32_bits() and lower_32_bits() macros to split
up the pointer into two halves, and use the 64-bit version of the
code above unconditionally, that should both work on all architectures
without introducing any overhead.

	Arnd
