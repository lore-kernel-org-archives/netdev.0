From: akepner@sgi.com
Subject: Re: NAPI wait before enabling irq's [was Re: [Cbe-oss-dev] Spider
 DMA wrongness]
Date: Thu, 14 Dec 2006 12:51:14 -0800 (PST)
Message-ID: <Pine.LNX.4.61.0612141244160.30447@localhost.localdomain>
References: <OFBF8BBD4B.0E5AEA34-ON8725721F.005D5313-8625721F.005EAC5D@us.ibm.com>
 <1162931892.28571.497.camel@localhost.localdomain> <20061214205432.GA4329@austin.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	James K Lewis <jklewis@us.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>,
	"cbe-oss-dev@ozlabs.org" <cbe-oss-dev@ozlabs.org>,
	cbe-oss-dev-bounces+jklewis=us.ibm.com@ozlabs.org,
	Christoph Hellwig <hch@lst.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from omx2-ext.sgi.com ([192.48.171.19]:51979 "EHLO omx2.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932928AbWLNVUH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Dec 2006 16:20:07 -0500
To: Linas Vepstas <linas@austin.ibm.com>
In-Reply-To: <20061214205432.GA4329@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 14 Dec 2006, Linas Vepstas wrote:

> On Wed, Nov 08, 2006 at 07:38:12AM +1100, Benjamin Herrenschmidt wrote:
>>
>> What about Linas patches to do interrupt mitigation with NAPI polling ?
>> That didn't end up working ?
>
> It seems to be "working as designed", which is different than "working
> as naively expected".
>
> For large packets:
> -- a packet comes in
> -- rx interrupt generated
> -- rx interrupts turned off
> -- tcp poll function runs, receives packet
> -- completes all work before next packet has arrived,
>   so interupts are turned back on.
> -- go to start
>
> This results in a high number of interrupts, and a high cpu usage.
> We were able to prove that napi works by stalling in the poll function
> just long enough to allow the next packet to arrive.  In this case,
> napi works great, and number of irqs is vastly reduced.
> ....

This sounds awfully familiar. We went through the same
with the tg3 driver on Altix. In that case we succeeded
getting interrupt coalescence added to the driver, which
ended up working pretty well for us. See the thread
beginning with:

http://oss.sgi.com/archives/netdev/2005-05/msg00497.html

if you're interested.

As for the "stalling NAPI" idea, Jamal did a bit of work
with that idea and wrote it up in:

www.kernel.org/pub/linux/kernel/people/hadi/docs/UKUUG2005.pdf

-- 
Arthur


