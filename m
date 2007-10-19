From: Brian Haley <brian.haley@hp.com>
Subject: Re: multicast: bug or "feature"
Date: Fri, 19 Oct 2007 16:39:24 -0400
Message-ID: <471915FC.1000604@hp.com>
References: <OFC9CC5B3C.F6B38A10-ON88257379.006F6FDE-88257379.006FE742@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:55158 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760552AbXJSUjw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 16:39:52 -0400
In-Reply-To: <OFC9CC5B3C.F6B38A10-ON88257379.006F6FDE-88257379.006FE742@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

David Stevens wrote:
>         From looking at the code, it appears that validate
> source is failing just because of the rp_filter. Do you have
> rp_filter set to nonzero?
>         If so, it may do what you want just by setting that
> to 0:
> 
> sysctl -w net.ipv4.conf.all.rp_filter=0

rp_filter is set to zero, it's the "if (res.type != RTN_UNICAST)" check 
in fib_validate_source() that's doing it.  If I add a new 
"accept_local_addr" sysctl to ipv4_devconf to allow RTN_LOCAL here, 
everything works just fine.  I just don't know how palatable that would 
be to upstream...

-Brian
