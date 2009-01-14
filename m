From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 05/34]bnx2x: Setting the GSO_TYPE with LRO
Date: Wed, 14 Jan 2009 13:12:06 -0800 (PST)
Message-ID: <20090114.131206.193936587.davem@davemloft.net>
References: <20090114201826.GA23648@gondor.apana.org.au>
	<1231964842.3010.46.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, eilong@broadcom.com,
	netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55885
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755831AbZANVMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 16:12:05 -0500
In-Reply-To: <1231964842.3010.46.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 14 Jan 2009 20:27:22 +0000

> On Thu, 2009-01-15 at 07:18 +1100, Herbert Xu wrote:
> > Eilon Greenstein <eilong@broadcom.com> wrote:
> > >> 
> > > This is far from bullet proof solution, but IMHO it is better set then
> > > not  this way, you stand a chance (depending on the output device
> > > capabilities)
> > 
> > The question is simple, does your hardware guarantee that on
> > output GSO will turn the packet into exactly the same sequence
> > of packets that was seen on input, with no changes (apart from
> > what the stack would have done to them anyway, e.g., TTL update)
> > whatsoever?
> > 
> > If not then you mustn't set this and also you must disable it
> > if forwarding/bridging is used.
> 
> The driver just has to cooperate with dev_disable_lro() in order for the
> forwarding/bridging code to disable it.  Then skb_warn_if_lro() should
> catch the case where the user mistakenly turns it back on.  However,
> setting gso_type on input subverts this check.

Right, setting gso_type here is absolutely wrong.
