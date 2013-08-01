From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] tcp_metrics: rearrange fields to avoid holes
Date: Thu, 01 Aug 2013 16:13:42 +0800
Message-ID: <1375344822.7780.17.camel@cr0>
References: <1375240402.22980.5.camel@cr0>
	 <20130730.232639.178259761581407616.davem@davemloft.net>
	 <1375325311.7780.9.camel@cr0>
	 <20130801.001551.84126063849926109.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	edumazet@google.com, ycheng@google.com, ncardwell@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33625 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750742Ab3HAIOS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Aug 2013 04:14:18 -0400
In-Reply-To: <20130801.001551.84126063849926109.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-01 at 00:15 -0700, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Thu, 01 Aug 2013 10:48:31 +0800
> 
> > Please teach me how to do that?
> 
> struct inet_addr {
> 	union {
> 		u32	v4;
> 		u32	v6[4];
> 	};
> };
> 
> ie. exactly what that code is using already.
> 
> And it's called called inetpeer_addr, we have it already, there is no
> need to make something new.
> 
> Making this code use a structure with completely unnecessary and
> unused members is pointless and a step backwards.

Ah, I was thinking to keep it compatible with sockaddr*, actually this
is indeed unnecessary. I am going to define something like:

struct inet_addr_base {
        union {
                struct in_addr  sin_addr;
                struct in6_addr sin6_addr;
        };
        unsigned short int      sin_family;
};

which could used by bridge multicast code too.

Thanks for the hint.
