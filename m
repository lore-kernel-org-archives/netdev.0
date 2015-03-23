From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [v3 PATCH 9/9] rhashtable: Add immediate rehash during insertion
Date: Mon, 23 Mar 2015 21:56:32 +0000
Message-ID: <20150323215632.GA22099@casper.infradead.org>
References: <20150323134955.GA16328@gondor.apana.org.au>
 <E1Ya2kO-0004JD-Om@gondolin.me.apana.org.au>
 <20150323165033.GD20752@casper.infradead.org>
 <20150323214422.GA19938@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:59283 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752214AbbCWV4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 17:56:34 -0400
Content-Disposition: inline
In-Reply-To: <20150323214422.GA19938@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/24/15 at 08:44am, Herbert Xu wrote:
> I specifically made it this way because I don't think the users
> should be touching the actual limit.  This is something that you
> always want to enable unless you're in the situation of netfilter
> where you don't care.
> 
> If you did care then 16 is sort of intrinsic to the 32-bit hash
> that we're using.  Going below doesn't make much sense because
> you may run into false warnings due to double rehashes (that's
> how I discovered 4 was uesless, very quickly :) Remember the
> rehash is only there to detect pathological cases where people
> are actively attacking us.  Otherwise the 100% utilisation check
> will kick in.
> 
> Going above 16 means that you're hashing multiple objects with
> the same key.  Then you'd want to disable this altogether.
> 
> The rhashtable already has too many knobs and I don't want to
> add anything unnecessary to rhashtable_params.

OK. I can certinaly live with this. You are certinaly right that
simplicity isn't a bad move here. Thanks for being patience and
answering all the questions.

Acked-by: Thomas Graf <tgraf@suug.ch>
