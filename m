From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: route.c:645 suspicious rcu_dereference_check()
Date: Fri, 31 Aug 2012 04:50:14 -0700
Message-ID: <1346413814.2591.7.camel@edumazet-glaptop>
References: <20120828175734.41b17a6c@mj>
	 <1346193187.3571.21.camel@edumazet-glaptop>
	 <20120830.133433.566450758375930776.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: proski@gnu.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:54943 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752033Ab2HaLuR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2012 07:50:17 -0400
Received: by dady13 with SMTP id y13so1913455dad.19
        for <netdev@vger.kernel.org>; Fri, 31 Aug 2012 04:50:16 -0700 (PDT)
In-Reply-To: <20120830.133433.566450758375930776.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-08-30 at 13:34 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 28 Aug 2012 15:33:07 -0700
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > [PATCH] ipv4: must use rcu protection while calling fib_lookup
> > 
> > Following lockdep splat was reported by Pavel Roskin :
>  ...
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Reported-by: Pavel Roskin <proski@gnu.org>
> 
> Applied, thanks.
> 
> It looks like the redirect handlers might have the same problem?

Hi David

Correct me if I am wrong, but redirect handlers should all run under
rcu_read_lock() protection already.

rcu_read_lock() is done in ip_local_deliver_finish() or
ip_rt_send_redirect() for the forward path.

And above of them, we also have rcu_read_lock() done in
__netif_receive_skb()
