From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4]: powerpc/cell spidernet low watermark patch.
Date: Fri, 18 Aug 2006 14:25:13 -0700 (PDT)
Message-ID: <20060818.142513.29571851.davem@davemloft.net>
References: <20060811170813.GJ10638@austin.ibm.com>
	<1155771820.11312.116.camel@localhost.localdomain>
	<20060818192356.GD26889@austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Jens.Osterkamp@de.ibm.com, jklewis@us.ibm.com, arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:48835
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751450AbWHRVZK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 17:25:10 -0400
To: linas@austin.ibm.com
In-Reply-To: <20060818192356.GD26889@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: linas@austin.ibm.com (Linas Vepstas)
Date: Fri, 18 Aug 2006 14:23:56 -0500

> On Thu, Aug 17, 2006 at 01:43:40AM +0200, Benjamin Herrenschmidt wrote:
> > 
> > Sounds good (without actually looking at the code though :), that was a
> > long required improvement to that driver. Also, we should probably look
> > into using NAPI polling for tx completion queue as well, no ?
> 
> Just for a lark, I tried using NAPI polling, while disabling all TX
> interrupts. Performance was a disaster: 8Mbits/sec, fom which I conclude
> that the tcp ack packets do not flow back fast enough to allw reliance
> on NAPI polling for transmit.

The idea is to use NAPI polling with TX interrupts disabled.

We're not saying to use the RX interrupt as the trigger for
RX and TX work.  Rather, either of RX or TX interrupt will
schedule the NAPI poll.
