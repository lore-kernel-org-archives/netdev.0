From: Bill Fink <billfink@mindspring.com>
Subject: Re: [net-next-2.6 PATCH 2/5] ixgbe: drop support for UDP in RSS
 hash generation
Date: Tue, 20 Jul 2010 02:07:54 -0400
Message-ID: <20100720020754.135b5ff7.billfink@mindspring.com>
References: <20100719235831.14112.14175.stgit@localhost.localdomain>
	<20100719235925.14112.65890.stgit@localhost.localdomain>
	<20100719.202417.218061462.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com, alexander.h.duyck@intel.com,
	donald.c.skidmore@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-mealy.atl.sa.earthlink.net ([209.86.89.69]:56868 "EHLO
	elasmtp-mealy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932065Ab0GTGH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 02:07:57 -0400
In-Reply-To: <20100719.202417.218061462.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 19 Jul 2010, David Miller wrote:

> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Mon, 19 Jul 2010 16:59:27 -0700
> 
> > From: Alexander Duyck <alexander.h.duyck@intel.com>
> > 
> > This change removes UDP from the supported protocols for RSS hashing.  The
> > reason for removing this protocol is because IP fragmentation was causing a
> > network flow to be broken into two streams, one for fragmented, and one for
> > non-fragmented and this in turn was causing out-of-order issues.
> > 
> > Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> > Acked-by: Don Skidmore <donald.c.skidmore@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> 
> Applied.

Should there be a /proc or ethtool setting for whether or not to
use RSS hashing for UDP flows?  I would think that for many common
UDP applications, IP fragmentation would not be an issue because
they often tend to use sub-MTU sized datagrams.  And of course
UDP does not guarantee in-order delivery in any event.  Then a
remaining issue is what the default setting of such an option
should be.  I would lean to having it enabled by default, but
I can also see the safety argument for having it off by default.

						-Bill
