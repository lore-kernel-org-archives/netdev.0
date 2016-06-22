From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 2/2] tcp: reduce cpu usage when SO_SNDBUF is
 set
Date: Wed, 22 Jun 2016 11:51:19 -0700
Message-ID: <1466621479.6850.75.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1466608332.git.jbaron@akamai.com>
	 <c873de17bfcf341eafda5ee7762c3f2c26579ff1.1466608332.git.jbaron@akamai.com>
	 <1466616854.6850.69.camel@edumazet-glaptop3.roam.corp.google.com>
	 <576AD666.7050809@akamai.com>
	 <1466621021.6850.71.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jason Baron <jbaron@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:32776 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400AbcFVSvt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 14:51:49 -0400
Received: by mail-pa0-f66.google.com with SMTP id ts6so4555682pac.0
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 11:51:20 -0700 (PDT)
In-Reply-To: <1466621021.6850.71.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-06-22 at 11:43 -0700, Eric Dumazet wrote:
> On Wed, 2016-06-22 at 14:18 -0400, Jason Baron wrote:
> > 
> 
> > 
> > For 1/2, the getting the correct memory barrier, should I re-submit
> > that as a separate patch?
> 
> Are you sure a full memory barrier (smp_mb() is needed ?
> 
> Maybe smp_wmb() would be enough ?
> 
> (And smp_rmb() in tcp_poll() ?)

Well, in tcp_poll() smp_mb__after_atomic() is fine as it follows 
set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);

(although we might add a comment why we should keep
sk_set_bit(SOCKWQ_ASYNC_NOSPACE, sk) before the set_bit() !)

But presumably smp_wmb() would be enough in tcp_check_space()
