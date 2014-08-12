From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [PATCH stable 3.4 2/2] ipv4: avoid parallel route cache gc
 executions
Date: Tue, 12 Aug 2014 20:50:37 +0200
Message-ID: <1407869437.27163.6.camel@localhost>
References: <fc0168a71c064457c18f2563371176380d0012c7.1407796232.git.mleitner@redhat.com>
	 <ffd56913c060fc717a74b87ba1a154125c9db2c4.1407796232.git.mleitner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60571 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753895AbaHLSuo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Aug 2014 14:50:44 -0400
In-Reply-To: <ffd56913c060fc717a74b87ba1a154125c9db2c4.1407796232.git.mleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mo, 2014-08-11 at 19:41 -0300, Marcelo Ricardo Leitner wrote:
> When rt_intern_hash() has to deal with neighbour cache overflowing,
> it triggers the route cache garbage collector in an attempt to free
> some references on neighbour entries.
> 
> Such call cannot be done async but should also not run in parallel with
> an already-running one, so that they don't collapse fighting over the
> hash lock entries.
> 
> This patch thus blocks parallel executions by ignoring the call if
> garbage collector is already running on another CPU.
> 
> We don't use a spinlock for it because now it runs on a work queue and
> we want it to be schedulable in-between the hash indexes.
> 
> Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
> Cc: Hannes Frederic Sowa <hannes@redhat.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
