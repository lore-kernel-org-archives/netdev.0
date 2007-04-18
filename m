From: David Miller <davem@davemloft.net>
Subject: Re: [BRIDGE] Unaligned access on IA64 when comparing ethernet
 addresses
Date: Wed, 18 Apr 2007 01:28:04 -0700 (PDT)
Message-ID: <20070418.012804.95897126.davem@davemloft.net>
References: <20070417.130929.59470175.davem@davemloft.net>
	<20070417133723.00031f82@mini>
	<4625BE2C.1030801@sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	bridge@lists.osdl.org, devel@openvz.org
To: xemul@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55201
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933058AbXDRI2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2007 04:28:01 -0400
In-Reply-To: <4625BE2C.1030801@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelianov <xemul@sw.ru>
Date: Wed, 18 Apr 2007 10:43:56 +0400

> [snip]
> 
> > --- linux-2.6.orig/net/bridge/br_private.h	2007-04-17
> > 13:26:48.000000000 -0700 +++ linux-2.6/net/bridge/br_private.h
> > 2007-04-17 13:30:29.000000000 -0700 @@ -36,7 +36,7 @@
> >  {
> >  	unsigned char	prio[2];
> >  	unsigned char	addr[6];
> > -};
> > +} __attribute__((aligned(8)));
> 
> Why "8"? Mustn't it be "16"? Address is to be 2-bytes aligned...

Actually it could be made "2", the aligned() attribute is
in bytes, not bits.
