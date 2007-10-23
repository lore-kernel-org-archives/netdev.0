From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] - trivial - Improve appletalk checksum calculation
Date: Mon, 22 Oct 2007 18:36:28 -0700
Message-ID: <1193103388.5132.38.camel@localhost>
References: <1193081779.5132.24.camel@localhost>
	 <20071022.173545.74561992.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:2219 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751029AbXJWByp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 21:54:45 -0400
In-Reply-To: <20071022.173545.74561992.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-10-22 at 17:35 -0700, David Miller wrote:
> Your code is rotating bit 15 down by one bit and bits 0-14 up by one
> bit.

Yes, a 16 bit rotate left.

There was a discussion a few years ago:
http://oss.sgi.com/archives/netdev/2003-10/msg00734.html

>From the spec:

Implementers of DDP should treat generating the checksum as an optional
feature. The 16-bit DDP checksum is computed as follows:

CkSum := 0 ;
FOR each datagram byte starting with the byte immediately following this
Checksum field
REPEAT the following algorithm:
          CkSum := CkSum + byte; (unsigned addition)
          Rotate CkSum left one bit, rotating the
              most significant bit in least significant bit;
IF, at the end, CkSum = 0 THEN
          CkSum := $FFFF (all ones).

Reception of a datagram with CkSum equal to 0 implies that a checksum is
not performed.



