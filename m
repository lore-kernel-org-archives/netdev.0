From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [ofa-general] NetEffect, iw_nes and kernel warning
Date: Fri, 30 Jan 2009 08:25:23 -0800
Message-ID: <20090130082523.0fb8fb60@extreme>
References: <adaljsvwbkm.fsf@cisco.com>
	<20090130065721.GA4886@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>, davem@davemloft.net,
	aluno3@poczta.onet.pl, general@lists.openfabrics.org,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56256 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750824AbZA3QZZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2009 11:25:25 -0500
In-Reply-To: <20090130065721.GA4886@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 30 Jan 2009 17:57:21 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Roland Dreier <rdreier@cisco.com> wrote:
> > 
> > OK, thanks... what confused me is that several other drivers also do
> > skb_linearize() in their hard_start_xmit method... eg bnx2x,
> > via-velocity, mv643xx_eth.  So there are several other lurking bugs to
> > deal with here I guess.
> 
> I don't know about the rest but bnx2x is certainly OK since it
> only does so with IRQ enabled.  It is legal to call skb_linearize
> as long as you're sure that IRQs are enabled, which is always the
> case for hard_start_xmit upon entry.
> 
> So the only time you can't call it in hard_start_xmit is if you've
> just disabled IRQs yourself.

Or netconsole.
netconsole calls start_xmit from IRQ 
but it is safe since netconsole doesn't send fragmented skb's
