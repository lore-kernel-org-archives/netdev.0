From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] NF_CONNTRACK_H323 must depend on (IPV6 || IPV6=n)
Date: Sun, 28 Jan 2007 15:53:48 -0800 (PST)
Message-ID: <20070128.155348.39160134.davem@davemloft.net>
References: <20070127234928.64d8e437.akpm@osdl.org>
	<20070128114148.b8067721.randy.dunlap@oracle.com>
	<20070128222136.GZ6017@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, akpm@osdl.org,
	linux-kernel@vger.kernel.org, netfilter@lists.netfilter.org,
	netdev@vger.kernel.org
To: bunk@stusta.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46376
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933015AbXA1Xxu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jan 2007 18:53:50 -0500
In-Reply-To: <20070128222136.GZ6017@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Sun, 28 Jan 2007 23:21:37 +0100

> On Sun, Jan 28, 2007 at 11:41:48AM -0800, Randy Dunlap wrote:
> >...
> > net/built-in.o: In function `q931_help':
> > nf_conntrack_h323_main.c:(.text.q931_help+0x6ad): undefined reference to `ip6_route_output'
> > nf_conntrack_h323_main.c:(.text.q931_help+0x6c3): undefined reference to `ip6_route_output'
> >...
> 
> You didn't send your .config, but it seems you had CONFIG_IPV6=m and
> CONFIG_NF_CONNTRACK_H323=y.
> 
> In this case, the untested patch below should fix it.
> 
> > ~Randy
> 
> cu
> Adrian
> 
> 
> <--  snip  -->
> 
> 
> CONFIG_IPV6=m, CONFIG_NF_CONNTRACK_H323=y results in a compile error.
> 
> Fix this by letting NF_CONNTRACK_H323 depend on (IPV6 || IPV6=n).
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Adrian is this the correct way to constrain the selection between
"n" and "m" in this kind of situation?  I thought doing something
like "depends on IPV6" is sufficient to achieve that?
