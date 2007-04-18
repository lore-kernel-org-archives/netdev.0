From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [BRIDGE] Unaligned access on IA64 when comparing ethernet
 addresses
Date: Wed, 18 Apr 2007 07:44:39 -0700
Message-ID: <20070418074439.1ba41718@localhost.localdomain>
References: <20070417.130929.59470175.davem@davemloft.net>
	<20070417133723.00031f82@mini>
	<4625BE2C.1030801@sw.ru>
	<20070418.012804.95897126.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: xemul@sw.ru, netdev@vger.kernel.org, bridge@lists.osdl.org,
	devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34377 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992695AbXDROu2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Apr 2007 10:50:28 -0400
In-Reply-To: <20070418.012804.95897126.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 18 Apr 2007 01:28:04 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Pavel Emelianov <xemul@sw.ru>
> Date: Wed, 18 Apr 2007 10:43:56 +0400
> 
> > [snip]
> > 
> > > --- linux-2.6.orig/net/bridge/br_private.h	2007-04-17
> > > 13:26:48.000000000 -0700 +++ linux-2.6/net/bridge/br_private.h
> > > 2007-04-17 13:30:29.000000000 -0700 @@ -36,7 +36,7 @@
> > >  {
> > >  	unsigned char	prio[2];
> > >  	unsigned char	addr[6];
> > > -};
> > > +} __attribute__((aligned(8)));
> > 
> > Why "8"? Mustn't it be "16"? Address is to be 2-bytes aligned...
> 
> Actually it could be made "2", the aligned() attribute is
> in bytes, not bits.

It could be 2 but 8 might allow a compiler on a 64 bit platform
to be smarter in comparisons and assignments. For 2.6.22, I'll make
a nicer version similar to ktime_t.
