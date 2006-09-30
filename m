From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 6/6]: powerpc/cell spidernet refine locking
Date: Fri, 29 Sep 2006 19:47:52 -0700
Message-ID: <20060929194752.2194f94f.akpm@osdl.org>
References: <20060929230552.GG6433@austin.ibm.com>
	<20060929232911.GN6433@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	James K Lewis <jklewis@us.ibm.com>,
	linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
	linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:60101 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750696AbWI3Cv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2006 22:51:29 -0400
To: linas@austin.ibm.com (Linas Vepstas)
In-Reply-To: <20060929232911.GN6433@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 29 Sep 2006 18:29:11 -0500
linas@austin.ibm.com (Linas Vepstas) wrote:

> The transmit side of the spider ethernet driver currently
> places locks around some very large chunks of code. This
> results in a fair amount of lock contention is some cases. 
> This patch makes the locks much more fine-grained, protecting
> only the cirtical sections. One lock is used to protect 
> three locations: the queue head and tail pointers, and the 
> queue low-watermark location.

You have spider_net_set_low_watermark() walking the tx_chain outside
tx_chain.lock.  Are you sure about that?
