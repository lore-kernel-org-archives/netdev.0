From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: PPPoE performance regression
Date: Wed, 13 Jun 2012 11:55:41 -0400
Message-ID: <20120613155541.GD2361@kvack.org>
References: <1339143949.24571.72.camel@dualcore.traverse> <1339144110.13998.1.camel@i7.infradead.org> <1339144954.24571.80.camel@dualcore.traverse> <1339147045.13998.3.camel@i7.infradead.org> <1339289425.2661.27.camel@laptop> <1339317136.2851.54.camel@shinybook.infradead.org> <1339581421.11011.18.camel@shinybook.infradead.org> <1339595401.11011.48.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nathan Williams <nathan@traverse.com.au>,
	Karl Hiramoto <karl@hiramoto.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Paul Mackerras <paulus@samba.org>,
	John Crispin <blogic@openwrt.org>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:56793 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751324Ab2FMPzm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2012 11:55:42 -0400
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

Does this actually work?  Could the skb not end up sitting on the receive 
queue of a user socket indefinitely, deferring all further transmits?  From 
an ISP point of view, PPPoE and L2TP are most typically used on links where 
the congestion point is not the local interface the packets are being pumped 
into (think of the vast majority of ethernet based DSL modems), and this 
kind of transmit overhead is a pure waste of CPU cycles.  The only solution 
that generically works in most PPPoE/L2TP situations is to shape outgoing 
traffic to the speed of limiting link.

Maybe there's a PPP extension that does flow control...

		-ben
