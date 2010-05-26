From: Anton Blanchard <anton@samba.org>
Subject: Re: Warning in net/ipv4/af_inet.c:154
Date: Wed, 26 May 2010 13:19:43 +1000
Message-ID: <20100526031943.GA28295@kryten>
References: <20100525115813.GA28063@kryten>
 <1274801229.5020.80.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:56256 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759164Ab0EZDYW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 May 2010 23:24:22 -0400
Content-Disposition: inline
In-Reply-To: <1274801229.5020.80.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

> > Which is:
> > 
> >         WARN_ON(sk->sk_forward_alloc);
> > 
> 
> Yes, the infamous one :)
> 
> Is it reproductible ? What kind of workload is it ?
> What is the NIC involved ?

It was running sysbench against a postgresql database over localhost. In
each case I checked, sk_forward_alloc was less than one page.

I notice we update sk_forward_alloc in sk_mem_charge and sk_mem_uncharge.
Since it isn't an atomic variable I went looking for a lock somewhere in
the call chain (first thought was the socket lock). I couldn't find
anything, but I could easily be missing something.

Anton
