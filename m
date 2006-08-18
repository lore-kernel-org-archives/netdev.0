From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 2/4]: powerpc/cell spidernet low watermark patch.
Date: Fri, 18 Aug 2006 14:23:56 -0500
Message-ID: <20060818192356.GD26889@austin.ibm.com>
References: <20060811170337.GH10638@austin.ibm.com> <20060811170813.GJ10638@austin.ibm.com> <1155771820.11312.116.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org,
	Jens Osterkamp <Jens.Osterkamp@de.ibm.com>,
	James K Lewis <jklewis@us.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:52120 "EHLO
	e32.co.us.ibm.com") by vger.kernel.org with ESMTP id S932483AbWHRTX6
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 15:23:58 -0400
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Content-Disposition: inline
In-Reply-To: <1155771820.11312.116.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 17, 2006 at 01:43:40AM +0200, Benjamin Herrenschmidt wrote:
> 
> Sounds good (without actually looking at the code though :), that was a
> long required improvement to that driver. Also, we should probably look
> into using NAPI polling for tx completion queue as well, no ?

Just for a lark, I tried using NAPI polling, while disabling all TX
interrupts. Performance was a disaster: 8Mbits/sec, fom which I conclude
that the tcp ack packets do not flow back fast enough to allw reliance
on NAPI polling for transmit.

I was able to get as high as 960 Mbits/sec in unusal circumstances, 
at 100% cpu usage. Oprofile indicates that the next major improvement
would be to add scatter/gather, which I'll take a shot at next week,
if I don't get interrupted. However, I'm getting interrupted a lot these
days.

--linas
