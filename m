From: John Heffner <jheffner@psc.edu>
Subject: Re: MTU probing bug?
Date: Tue, 25 Jul 2006 09:56:38 -0400
Message-ID: <44C62316.9080501@psc.edu>
References: <20060725.001744.26930215.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:5322 "EHLO mailer1.psc.edu")
	by vger.kernel.org with ESMTP id S932294AbWGYN4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2006 09:56:44 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060725.001744.26930215.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> John, have a look at this code in tcp_write_timeout():
> 
> 		mss = min(sysctl_tcp_base_mss,
> 		          tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_low)/2);
> 		mss = max(mss, 68 - tp->tcp_header_len);
> 
> That first line looks like it should be a max() instead
> of a min().
> 
> tcp_base_mss is the smallest MSS we should use, therefore
> we should make sure the "mss" is at least that large.
> 
> It's also possible that I misread the intention of this code :) From
> what I read, it is trying to half the MSS in use and adjust the MTU
> search low point to be based upon this new value.

No, the min() is what's intended here.  The base_mss is where you want 
to start searching from.  So, on black hole detection, you drop 
immediatly down to the base.  The base is configurable, because making 
it higher can make searching faster.  If it's still too high for some 
links, you halve it again on successive timeouts.

   -John
