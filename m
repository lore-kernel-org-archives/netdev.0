From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Extensible hashing and RCU
Date: Thu, 22 Feb 2007 11:24:51 -0800
Message-ID: <20070222112451.47490630@freekitty>
References: <f2b55d220702211315h1266d25el4a0f46c4fb65e12a@mail.gmail.com>
	<20070222.010638.27784211.davem@davemloft.net>
	<f2b55d220702220300t4734dd9bxb97f8f63724817f9@mail.gmail.com>
	<20070222.030755.130841135.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: medwards.linux@gmail.com, johnpol@2ka.mipt.ru, dada1@cosmosbay.com,
	akepner@sgi.com, linux@horizon.com, netdev@vger.kernel.org,
	bcrl@kvack.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34689 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751777AbXBVT1p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Feb 2007 14:27:45 -0500
In-Reply-To: <20070222.030755.130841135.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 22 Feb 2007 03:07:55 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: "Michael K. Edwards" <medwards.linux@gmail.com>
> Date: Thu, 22 Feb 2007 03:00:32 -0800
> 
> > Besides, RCUing a hash of any sort sounds like a nightmare, whereas
> > something like a splay tree is reputed to be very straightforward to
> > make "persistent" in the functional-programming sense.  I haven't
> > coded that one myself but surely it's in the current edition of Knuth.
> 
> Knuth tends to be thorough, yet archaic. :-)
> 
> > You are much better off obtaining all per-flow state with a
> > single data structure lookup.  It would be kind of nice if state for
> > other layers like IPSec and NAT could live there too.
> 
> This is the eventual idea.
> 
> > By the way, are these flows unidirectional or bidirectional?
> 
> The entries created by Robert's TRASH are unidirectional, they have to
> be because the path from remote to localhost is different than the
> path from localhost to remote :-)
> 
> But we don't need to do a socket demux on packet output, we just
> need a plain route (+ firewall, IPSEC, etc.) destination cache
> entry for that.
> -


There are a number of other lock-less algorithms rather than simple RCU
that might be worth exploring. A number of them rely on a working implementation
of compare-exchange; that can be a problem since some architectures don't have
a fast way of doing that.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
