From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket
 filter
Date: Tue, 20 Nov 2007 17:39:28 -0800 (PST)
Message-ID: <20071120.173928.53148729.davem@davemloft.net>
References: <20071119.142313.63549156.davem@davemloft.net>
	<20071120002945.91fafb2b.billfink@mindspring.com>
	<20071120140518.GA1502@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: billfink@mindspring.com, wangchen@cn.fujitsu.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51732
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759041AbXKUBj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 20:39:29 -0500
In-Reply-To: <20071120140518.GA1502@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi@firstfloor.org>
Date: Tue, 20 Nov 2007 15:05:18 +0100

> On Tue, Nov 20, 2007 at 12:29:45AM -0500, Bill Fink wrote:
> > While I agree with your analysis that it could be worked around,
> > who knows how all the various SNMP monitoring applications out there
> > would interpret such an unusual event.  I liked Stephen's suggestion
> > of a deferred decrement that would insure the counter didn't ever
> > run backwards.  But the best approach seems to be just not to count
> > it in the first place until tha application has actually received
> > the packet, since as Herbert pointed out, that's what the RFC
> > actually specifies for the meaning of the udpInDatagrams counter.
> 
> Together with another counter that counts "edge datagrams received"
> that would be an excellent idea.
> 
> Here's a patch.

NFS and friends that use the ->data_ready() callback needs to
be updated as well.  Please fix this and resubmit, thanks.
