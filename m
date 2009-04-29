From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] pcnet32: Remove pointless memory barriers
Date: Tue, 28 Apr 2009 22:16:05 -0700 (PDT)
Message-ID: <20090428.221605.71993506.davem@davemloft.net>
References: <1240945659.8819.9.camel@Maple>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pcnet32@verizon.net
To: john.dykstra1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57609
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751472AbZD2FQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 01:16:12 -0400
In-Reply-To: <1240945659.8819.9.camel@Maple>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Dykstra <john.dykstra1@gmail.com>
Date: Tue, 28 Apr 2009 19:07:39 +0000

> These two memory barriers in performance-critical paths are not needed
> on x86.  Even if some other architecture does buffer PCI I/O space
> writes, the existing memory-mapped I/O barriers are unlikely to be what
> is needed.
> 
> Signed-off-by: John Dykstra <john.dykstra1@gmail.com>

Any driver where these things are present usually has them
there for a reason.  Usually it's because the SGI guys really
did run into real problems without them on their huge
machines which can reorder PCI MMIO wrt. real memory operations.

I don't feel good applying this at all, given that I see no
evidence that there has been any investigation into how these
barriers got there in the first place.
