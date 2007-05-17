From: David Miller <davem@davemloft.net>
Subject: Re: RT patches expose netdev race [was Re: [RFC] [patch 2/2]
 powerpc 2.6.21-rt1: fix kernel hang and/or panic
Date: Wed, 16 May 2007 17:41:01 -0700 (PDT)
Message-ID: <20070516.174101.45179259.davem@davemloft.net>
References: <yyiirau5v8g.wl@toshiba.co.jp>
	<1179223742.32247.184.camel@localhost.localdomain>
	<20070517001801.GB4325@austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, tsutomu.owa@toshiba.co.jp,
	linuxppc-dev@ozlabs.org, mingo@elte.hu, tglx@linutronix.de,
	netdev@vger.kernel.org
To: linas@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45417
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755058AbXEQAky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 20:40:54 -0400
In-Reply-To: <20070517001801.GB4325@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: linas@austin.ibm.com (Linas Vepstas)
Date: Wed, 16 May 2007 19:18:02 -0500

> Hi,
> 
> On Tue, May 15, 2007 at 08:09:02PM +1000, Benjamin Herrenschmidt wrote:
> > On Tue, 2007-05-15 at 17:47 +0900, Tsutomu OWA wrote:
> > >   I encountered the following error when doing netperf from other machine 
> > > to Celleb running RT kernel.  PREEPT_NONE kernel works just fine as well.
> > 
> > Hrm... sounds a bit weird. I wonder if there's a locking bug in the
> > driver in the first place.
> > 
> > Linas, what's your take ?
> 
> Heh. I almost deleted the entire email thread cause it
> didn't say "spidernet" in the subject line. :-)
> Seriously, I really almost did ....
> 
> Since this is a long email; let me put a summary up front:
> I think the RT/premption patches are exposing some sort
> of race in the ip header handling code. The rest of the 
> note is forensics pointing to this.

skb->head should never ever be NULL.
