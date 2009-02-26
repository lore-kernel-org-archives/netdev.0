From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Treason uncloaked / Broken peer again
Date: Thu, 26 Feb 2009 11:30:58 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0902261105030.31742@wrl-59.cs.helsinki.fi>
References: <20090226085826.GA12498@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Greg Lindahl <greg@blekko.com>, Netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54631 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754795AbZBZJbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 04:31:01 -0500
In-Reply-To: <20090226085826.GA12498@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Feb 2009, Herbert Xu wrote:

> Greg Lindahl <greg@blekko.com> wrote:
> > 
> > I'm continuing to get hate mail from all over the planet. Can anyone
> > recommend a webpage which I could point to that explains how harmless
> > this message can be? Google returns lots of scary warnings. I would
> > write one myself but the complainers are already dubious of me.
> > 
> > It seems that most complainers are running < 2.6.14, which had a
> > header prediction bug.

Like I said, one possible way for you to try to avoid the situation (when 
the buggy receiver is not in your control) is to prevent window getting 
zero (ever). Either make sure your application is fast enough and/or 
increase tcp_rmem enough. Alternatively you could add some OUTPUT firewall 
to drop zero window advertizing ACKs altogether (not that I recommend 
such a solution :-)).

> Right, most of these instances are due to buggy receivers.  I
> suppose you can just point them to this or one of the previous
> threads and tell them to upgrade :)

Right, it's rather crude to have buggy kernel which sends past the 
receiver's advertized window, and then when it cannot cope the results of 
its own bug (and prints that message), put a blame on others who behave in 
a compliant way. Sadly, I'd think that such people might also refuse 
upgrade which is beyond ridiculous if they still keep complaining about 
that message. It is well known that such bugs exist in the old kernels but 
I guess nobody can convince all. This is btw why I recently suggested 
(when the Treason message was revised) that the notion about peer 
shrunking its window should be removed since it's not always the case.

Perhaps one should start sending blames to all who send past the 
receiver's advertized window... ;-) It's certainly very questionable 
behavior (In a quick browsing through RFCs I didn't find anything that
clearly forbids it, but it for sure at least SHOULD NOT, and RFC793
also has says what the send window is, however, it's just positive
wording, no opposite case spelled out).


-- 
 i.
