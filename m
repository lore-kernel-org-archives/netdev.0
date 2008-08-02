From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] inet6: Fix paramater issue of inet6_csk_xmit
Date: Sat, 2 Aug 2008 08:30:16 +0800
Message-ID: <20080802003016.GA24295@gondor.apana.org.au>
References: <48929C5B.5030108@cn.fujitsu.com> <E1KOqf7-0004lB-00@gondolin.me.apana.org.au> <20080801.021825.51896743.davem@davemloft.net> <20080801092548.GA18424@gondor.apana.org.au> <20080801115041.GA19124@gondor.apana.org.au> <20080801131453.GA19851@gondor.apana.org.au> <489322A9.3080906@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, yjwei@cn.fujitsu.com,
	netdev@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51925 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752271AbYHBAae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2008 20:30:34 -0400
Content-Disposition: inline
In-Reply-To: <489322A9.3080906@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 01, 2008 at 10:50:17AM -0400, Vlad Yasevich wrote:
>
> > +	inet->pmtudisc = transport->param_flags & SPP_PMTUD_ENABLE ?
> > +			 IP_PMTUDISC_DO : IP_PMTUDISC_DONT;
> 
> If you insist on doing this, you need to save the old value and restore
> it after ip_queue_xmit(). 
> 
> The reason is that PMTU discovery change on a specific transport or
> association should not affect the socket, since there could be multiple
> associations on a given socket.  Each association has it's own control.

Yes but they'll all pass through here so it'll get set to the
appropriate value.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
