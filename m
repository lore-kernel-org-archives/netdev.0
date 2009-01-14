From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 05/34]bnx2x: Setting the GSO_TYPE with LRO
Date: Wed, 14 Jan 2009 20:27:22 +0000
Message-ID: <1231964842.3010.46.camel@achroite>
References: <20090114201826.GA23648@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eilon Greenstein <eilong@broadcom.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:36065 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752260AbZANU12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 15:27:28 -0500
In-Reply-To: <20090114201826.GA23648@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-01-15 at 07:18 +1100, Herbert Xu wrote:
> Eilon Greenstein <eilong@broadcom.com> wrote:
> >> 
> > This is far from bullet proof solution, but IMHO it is better set then
> > not  this way, you stand a chance (depending on the output device
> > capabilities)
> 
> The question is simple, does your hardware guarantee that on
> output GSO will turn the packet into exactly the same sequence
> of packets that was seen on input, with no changes (apart from
> what the stack would have done to them anyway, e.g., TTL update)
> whatsoever?
> 
> If not then you mustn't set this and also you must disable it
> if forwarding/bridging is used.

The driver just has to cooperate with dev_disable_lro() in order for the
forwarding/bridging code to disable it.  Then skb_warn_if_lro() should
catch the case where the user mistakenly turns it back on.  However,
setting gso_type on input subverts this check.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

