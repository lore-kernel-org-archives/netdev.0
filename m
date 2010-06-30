From: Simon Horman <horms@verge.net.au>
Subject: Re: static inline int xfrm_mark_get() broken
Date: Wed, 30 Jun 2010 13:46:37 +0900
Message-ID: <20100630044637.GV2138@verge.net.au>
References: <4C28EE19.2090502@hsr.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andreas Steffen <andreas.steffen@hsr.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:41583 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750773Ab0F3Eqk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jun 2010 00:46:40 -0400
Content-Disposition: inline
In-Reply-To: <4C28EE19.2090502@hsr.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 28, 2010 at 08:46:49PM +0200, Andreas Steffen wrote:
> Hi,
> 
> experimenting with the new XFRM_MARK feature of the 2.6.34 kernel
> I found out that the extraction of the mark mask might accidentally
> work on 64 bit platforms but on 32 bit platforms the function is
> awfully broken. The rather trivial patch attached to this mail fixes
> the problem. Otherwise the XFRM_MARK feature seems quite promising!
> 
> Best regards
> 
> Andreas
> 
> ======================================================================
> Andreas Steffen                         e-mail: andreas.steffen@hsr.ch
> Institute for Internet Technologies and Applications
> Hochschule fuer Technik Rapperswil      phone:  +41 55 222 42 68
> CH-8640 Rapperswil (Switzerland)        mobile: +41 76 340 25 56
> ===========================================================[ITA-HSR]==

> --- linux/include/net/xfrm.h.ori	2010-06-28 18:53:28.229489876 +0200
> +++ linux/include/net/xfrm.h	2010-06-28 18:53:50.745487383 +0200
> @@ -1587,7 +1587,7 @@
>  static inline int xfrm_mark_get(struct nlattr **attrs, struct xfrm_mark *m)
>  {
>  	if (attrs[XFRMA_MARK])
> -		memcpy(m, nla_data(attrs[XFRMA_MARK]), sizeof(m));
> +		memcpy(m, nla_data(attrs[XFRMA_MARK]), sizeof(struct xfrm_mark));

This fix looks correct to me, but
I believe that sizeof(*m) is the preferred style.

>  	else
>  		m->v = m->m = 0;
>  

