From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 6/6]: powerpc/cell spidernet refine locking
Date: Mon, 2 Oct 2006 12:47:22 -0500
Message-ID: <20061002174722.GE4546@austin.ibm.com>
References: <20060929230552.GG6433@austin.ibm.com> <20060929232911.GN6433@austin.ibm.com> <20060929194752.2194f94f.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	James K Lewis <jklewis@us.ibm.com>,
	linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
	linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:43462 "EHLO e3.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S965171AbWJBRr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2006 13:47:26 -0400
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060929194752.2194f94f.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 29, 2006 at 07:47:52PM -0700, Andrew Morton wrote:
> On Fri, 29 Sep 2006 18:29:11 -0500
> linas@austin.ibm.com (Linas Vepstas) wrote:
> 
> > The transmit side of the spider ethernet driver currently
> > places locks around some very large chunks of code. This
> > results in a fair amount of lock contention is some cases. 
> > This patch makes the locks much more fine-grained, protecting
> > only the cirtical sections. One lock is used to protect 
> > three locations: the queue head and tail pointers, and the 
> > queue low-watermark location.
> 
> You have spider_net_set_low_watermark() walking the tx_chain outside
> tx_chain.lock.  Are you sure about that?

Yes. Its making an approximate count of the queue length, and I figured
that if its approximate to begin with, an unlocked version should be
just fine.

--linas
