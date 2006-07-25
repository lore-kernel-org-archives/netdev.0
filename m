From: David Miller <davem@davemloft.net>
Subject: Re: MTU probing bug?
Date: Tue, 25 Jul 2006 14:42:25 -0700 (PDT)
Message-ID: <20060725.144225.67885911.davem@davemloft.net>
References: <20060725.001744.26930215.davem@davemloft.net>
	<44C62316.9080501@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:34471
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964869AbWGYVmU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 17:42:20 -0400
To: jheffner@psc.edu
In-Reply-To: <44C62316.9080501@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Tue, 25 Jul 2006 09:56:38 -0400

> David Miller wrote:
> > John, have a look at this code in tcp_write_timeout():
> > 
> > 		mss = min(sysctl_tcp_base_mss,
> > 		          tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_low)/2);
> > 		mss = max(mss, 68 - tp->tcp_header_len);
> > 
> > That first line looks like it should be a max() instead
> > of a min().
> > 
> > tcp_base_mss is the smallest MSS we should use, therefore
> > we should make sure the "mss" is at least that large.
> > 
> > It's also possible that I misread the intention of this code :) From
> > what I read, it is trying to half the MSS in use and adjust the MTU
> > search low point to be based upon this new value.
> 
> No, the min() is what's intended here.  The base_mss is where you want 
> to start searching from.  So, on black hole detection, you drop 
> immediatly down to the base.  The base is configurable, because making 
> it higher can make searching faster.  If it's still too high for some 
> links, you halve it again on successive timeouts.

Thanks for the clarification John.

I find it interesting that black hole detection is handled
different from a normal probe failure.  I guess here we are
dealing with a more significant failure, so we should start
at the thing which is most guarenteed to work.

