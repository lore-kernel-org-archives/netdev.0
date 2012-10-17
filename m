From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: use ISO C standard for array in linux/xfrm.h
Date: Wed, 17 Oct 2012 10:27:31 +0200
Message-ID: <20121017082731.GB12671@secunet.com>
References: <1350402153-3889-1-git-send-email-nicolas.dichtel@6wind.com>
 <20121017054343.GA12671@secunet.com>
 <507E6362.1080009@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	davem@davemloft.net
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51822 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753267Ab2JQI1i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2012 04:27:38 -0400
Content-Disposition: inline
In-Reply-To: <507E6362.1080009@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 17, 2012 at 09:50:58AM +0200, Nicolas Dichtel wrote:
> We got a problem with "ip xfrm state add" when compiled with gcc 4.4.6.
> Error was "*** buffer overflow detected ***: ip terminated", because
> when we try to copy the key in struct xfrm_algo, the function
> strncpy() calls some builtin checks about the size of the
> destination buffer, which is 0. With the standard notation, there is
> no problem.

This is likely to be a gcc FORITFY bug. Try to build iproute2 with
the -D_FORTIFY_SOURCE=0 flag.
