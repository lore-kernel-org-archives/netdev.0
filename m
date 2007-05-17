From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: Resending: RT patches expose netdev race [was Re: [RFC] [patch 2/2] powerpc 2.6.21-rt1: fix kernel hang and/or panic
Date: Thu, 17 May 2007 12:38:46 -0500
Message-ID: <20070517173846.GF4325@austin.ibm.com>
References: <20070517002751.GC4325@austin.ibm.com> <1179362985.32247.252.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tsutomu OWA <tsutomu.owa@toshiba.co.jp>, linuxppc-dev@ozlabs.org,
	mingo@elte.hu, tglx@linutronix.de, cbe-oss-dev@ozlabs.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:48779 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756545AbXEQRiv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2007 13:38:51 -0400
Content-Disposition: inline
In-Reply-To: <1179362985.32247.252.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 17, 2007 at 10:49:45AM +1000, Benjamin Herrenschmidt wrote:
> 
> > I do not know why sk_buff->head would be null, or
> > would be set in a racy kind of way, or why the rt patches
> > would cause this. But the evidence implicates that.
> 
> Would it be possible that a locking bug in spidernet would cause it
> under some circumstances to get a stale skb pointer ?

The skb pointer should be brand-spanking new/fresh. 
It is passed to spidernet by the netdev->hard_start_xmit
callback:

    netdev->hard_start_xmit = &spider_net_xmit;

I'd expect that anything that hard_start_xmit() passed to 
a device driver should have a fully valid skb.  Locking
problems in spidernet could cause it to work with the wrong 
skb; however, in this case, the skb pointer is passed 
unmodified, directly to the spot where it fails.

Maybe there is some "make ip header fresh and clean on skb" call
that should have been made; if so, I don't know what it is. 

--linas
