From: David Miller <davem@davemloft.net>
Subject: Re: kernel panic with the newly merged md5 signature support
Date: Tue, 12 Dec 2006 14:25:23 -0800 (PST)
Message-ID: <20061212.142523.85408861.davem@davemloft.net>
References: <36718.81.105.127.245.1165873138.squirrel@www.solinno.co.uk>
	<60194.81.105.127.245.1165962133.squirrel@www.solinno.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42805
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932488AbWLLWZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Dec 2006 17:25:24 -0500
To: leigh@solinno.co.uk
In-Reply-To: <60194.81.105.127.245.1165962133.squirrel@www.solinno.co.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Leigh Brown" <leigh@solinno.co.uk>
Date: Tue, 12 Dec 2006 22:22:13 -0000 (GMT)

> I'm not sure what the correct way forward is.  Could these functions
> not be just:
> 
> struct tcp_md5sig_pool *__tcp_get_md5sig_pool(int cpu)
> {
>         struct tcp_md5sig_pool **p = tcp_md5_sig_pool;
> 	BUG_ON(!p);
> 	return *per_cpu_ptr(p, cpu);
> }
> 
> void __tcp_put_md5sig_pool(void) {
>         /* nuffin */
> }
> 
> In other words, can we assume that the pool is allocated when we call
> tcp_get_md5sig_pool?

I think the issue is that we need to get a balanced get_cpu()/put_cpu()
in there somehow.

I'll take a look at this later today, thanks for pointing it out.

