From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TSO trimming question
Date: Fri, 21 Dec 2007 20:58:35 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712212056220.31652@kivilampi-30.cs.helsinki.fi>
References: <20071221030648.389669c4.billfink@mindspring.com>
 <20071221.012720.67812056.davem@davemloft.net> <20071221092927.GA32434@gondor.apana.org.au>
 <20071221.013642.29817274.davem@davemloft.net> <20071221055822.8d977800.billfink@mindspring.com>
 <20071221135437.16fa63c8.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Netdev <netdev@vger.kernel.org>, John Heffner <jheffner@psc.edu>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35894 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752399AbXLUS6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 13:58:37 -0500
In-Reply-To: <20071221135437.16fa63c8.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Dec 2007, Bill Fink wrote:

> On Fri, 21 Dec 2007, Bill Fink wrote:
> 
> > Or perhaps even:
> > 
> > 	/* Ok, it looks like it is advisable to defer.  */
> > 	tp->tso_deferred = jiffies;
> > 
> > 	/* need to return a non-zero value to defer, which means won't
> > 	 * defer if jiffies == 0 but it's only a 1 in 4 billion event
> > 	 * (and avoids a compare/branch by not checking jiffies)
> > 	 /
> >         return jiffies;
> 
> Ack.  I introduced my own 64-bit to 32-bit issue (too late at night).
> How about:
> 
> 	/* Ok, it looks like it is advisable to defer.  */
> 	tp->tso_deferred = jiffies;
> 
> 	/* this won't defer if jiffies == 0 but it's only a 1 in
> 	 * 4 billion event (and avoids a branch)
> 	 */
> 	return (jiffies != 0);

I'm not sure how the jiffies work but is this racy as well?

Simple return tp->tso_deferred; should work, shouldn't it? :-)


-- 
 i.
