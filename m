From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [PATCH stable 3.4 1/2] ipv4: move route garbage collector to
 work queue
Date: Tue, 12 Aug 2014 20:50:04 +0200
Message-ID: <1407869404.27163.5.camel@localhost>
References: <fc0168a71c064457c18f2563371176380d0012c7.1407796232.git.mleitner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19119 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753895AbaHLSuK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Aug 2014 14:50:10 -0400
In-Reply-To: <fc0168a71c064457c18f2563371176380d0012c7.1407796232.git.mleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mo, 2014-08-11 at 19:41 -0300, Marcelo Ricardo Leitner wrote:
> Currently the route garbage collector gets called by dst_alloc() if it
> have more entries than the threshold. But it's an expensive call, that
> don't really need to be done by then.
> 
> Another issue with current way is that it allows running the garbage
> collector with the same start parameters on multiple CPUs at once, which
> is not optimal. A system may even soft lockup if the cache is big enough
> as the garbage collectors will be fighting over the hash lock entries.
> 
> This patch thus moves the garbage collector to run asynchronously on a
> work queue, much similar to how rt_expire_check runs.
> 
> There is one condition left that allows multiple executions, which is
> handled by the next patch.
> 
> Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
> Cc: Hannes Frederic Sowa <hannes@redhat.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,
Hannes
