From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: question on pktgen shutdown logic.
Date: Wed, 22 May 2013 16:22:01 -0700
Message-ID: <1369264921.3301.370.camel@edumazet-glaptop>
References: <519D519B.8040406@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:52553 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754726Ab3EVXWD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 19:22:03 -0400
Received: by mail-pd0-f175.google.com with SMTP id 6so1893301pdd.20
        for <netdev@vger.kernel.org>; Wed, 22 May 2013 16:22:02 -0700 (PDT)
In-Reply-To: <519D519B.8040406@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-22 at 16:15 -0700, Ben Greear wrote:
> While looking at pktgen.c in 3.9.3, I cannot explain how
> it does not race on shutdown.
> 
> The thread worker checks for pktgen_exiting, and will bail out
> of it's main loop and initiate cleanup if this is true.
> 
> The pg_net_exit sets the pktgen_exiting to true, and then
> proceedes to call
> 
> 		kthread_stop(t->tsk);
> 		kfree(t);
> 
> What I don't understand is what keeps the kfree(t) from happening
> before the thread has noticed pktgen_exiting is set and properly
> bailed out of it's loop and finished cleanup?

kthread_stop() is synchronous.
