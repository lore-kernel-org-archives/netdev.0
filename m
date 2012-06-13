From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: PPPoE performance regression
Date: Wed, 13 Jun 2012 12:31:08 -0400
Message-ID: <20120613163108.GE2361@kvack.org>
References: <1339143949.24571.72.camel@dualcore.traverse> <1339144110.13998.1.camel@i7.infradead.org> <1339144954.24571.80.camel@dualcore.traverse> <1339147045.13998.3.camel@i7.infradead.org> <1339289425.2661.27.camel@laptop> <1339317136.2851.54.camel@shinybook.infradead.org> <1339581421.11011.18.camel@shinybook.infradead.org> <1339595401.11011.48.camel@shinybook.infradead.org> <20120613155541.GD2361@kvack.org> <1339603894.14785.5.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nathan Williams <nathan@traverse.com.au>,
	Karl Hiramoto <karl@hiramoto.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Paul Mackerras <paulus@samba.org>,
	John Crispin <blogic@openwrt.org>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:57104 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752103Ab2FMQbK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2012 12:31:10 -0400
Content-Disposition: inline
In-Reply-To: <1339603894.14785.5.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 13, 2012 at 05:11:34PM +0100, David Woodhouse wrote:
> On Wed, 2012-06-13 at 11:55 -0400, Benjamin LaHaise wrote:
> > Does this actually work?  Could the skb not end up sitting on the
> > receive  queue of a user socket indefinitely, deferring all further
> > transmits?  From an ISP point of view, 
> 
> I haven't tried it; only compiled it. Certainly, the similar approach in
> PPPoATM in commit 9d02daf7 *does* work for limiting the bufferbloat and
> keeping the queues under control. And it'll let me do BQL for PPPoA.
> 
> I'm looking at this from the client side, not the ISP side. And in that
> case the local interface *is* the bottleneck. When it's a PPPoE over
> br2684 interface and it's full, we should stop the PPP netdev from
> spewing packets at it, rather than just dropping them.

I would contend that PPPoE over br2684 is not the common case.  The vast 
majority of users in client mode are going to be using PPPoE over an 
ethernet link to a DSL modem (or cable or wireless radios even).  Just look 
at what DSL modems are available for users in computer stores / what ISPs 
actually ship to their users.  Real ATM exposing devices are rare.

> On the ISP side if the skb ends up sitting on a receive queue of a user
> socket, and nothing is servicing that socket, surely the transmits on
> this channel weren't happening anyway?

True, but it's a design issue we've had to contend with elsewhere in the 
various tunnelling protocols.

Don't get me wrong: I am very much in favour of intelligent queue 
management, but this approach simply does not work for the vast majority 
of PPPoE users, while it adds overhead that will negatively impact access 
concentrators.  If you can somehow restrict the overhead to only impacting 
your use-case, that would be an improvement.

		-ben
-- 
"Thought is the essence of where you are now."
