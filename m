From: Paul Mackerras <paulus@samba.org>
Subject: Re: PPPoE performance regression
Date: Thu, 14 Jun 2012 16:18:10 +1000
Message-ID: <20120614061809.GA10453@drongo>
References: <1339143949.24571.72.camel@dualcore.traverse>
 <1339144110.13998.1.camel@i7.infradead.org>
 <1339144954.24571.80.camel@dualcore.traverse>
 <1339147045.13998.3.camel@i7.infradead.org>
 <1339289425.2661.27.camel@laptop>
 <1339317136.2851.54.camel@shinybook.infradead.org>
 <1339581421.11011.18.camel@shinybook.infradead.org>
 <1339595401.11011.48.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nathan Williams <nathan@traverse.com.au>,
	Karl Hiramoto <karl@hiramoto.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	John Crispin <blogic@openwrt.org>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:49044 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751191Ab2FNGSV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jun 2012 02:18:21 -0400
Content-Disposition: inline
In-Reply-To: <1339595401.11011.48.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 13, 2012 at 02:50:01PM +0100, David Woodhouse wrote:
> On Wed, 2012-06-13 at 10:57 +0100, David Woodhouse wrote:
> > This doesn't look *so* evil... if the basic concept of using
> > skb_orphan() and then setting our own destructor is OK, then I'll work
> > out the rest of the details and do it for l2tp too.
> 
> Stupid dwmw2. With patch this time...

> +static void pppoe_skb_destructor(struct sk_buff *skb)
> +{
> +	struct sock *sk = skb->sk;
> +	struct pppox_sock *po = pppox_sk(sk);
> +
> +	atomic_dec(&po->inflight);
> +	/* Schedule a call to ppp_output_wakeup(chan), if it was already blocked.
> +	   Mind for race conditions with another CPU which is in pppoe_xmit() 
> +	   right now. See commit 9d02daf7 in pppoatm. */
> +	sock_put(sk);
> +}

Umm, how does ppp_output_wakeup() actually get called?

Paul.
