From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 2/2] tcp: reduce cpu usage when SO_SNDBUF is
 set
Date: Wed, 22 Jun 2016 13:15:30 -0700
Message-ID: <1466626530.6850.77.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1466608332.git.jbaron@akamai.com>
	 <c873de17bfcf341eafda5ee7762c3f2c26579ff1.1466608332.git.jbaron@akamai.com>
	 <1466616854.6850.69.camel@edumazet-glaptop3.roam.corp.google.com>
	 <576AD666.7050809@akamai.com>
	 <1466621021.6850.71.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1466621479.6850.75.camel@edumazet-glaptop3.roam.corp.google.com>
	 <576AE4F7.4060204@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jason Baron <jbaron@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35017 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833AbcFVUPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 16:15:32 -0400
Received: by mail-pf0-f196.google.com with SMTP id t190so4799614pfb.2
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 13:15:32 -0700 (PDT)
In-Reply-To: <576AE4F7.4060204@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-06-22 at 15:20 -0400, Jason Baron wrote:


> hmm, I think we need the smp_mb() there. From
> tcp_poll() we have:
> 
> 1) set_bit(SOCK_NOSPACE, ...)  (write)
> 2) smp_mb__after_atomic();
> 3) if (sk_stream_is_writeable(sk)) (read)
> 
> while in tcp_check_space() its:
> 
> 1) the state that sk_stream_is_writeable() cares about (write)
> 2) smp_mb();
> 3) if (sk->sk_socket && test_bit(SOCK_NOSPACE,...) (read)


Oh right, thanks for checking.

> 
> So if we can show that there are sufficient barriers
> for #1 (directly above), maybe it can be down-graded or
> eliminated. But it would still seem somewhat fragile.
> 
> Note I didn't observe any missing wakeups here, but I
> just wanted to make sure we didn't miss any, since they
> can be quite hard to debug.
x
