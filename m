From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [PATCH stable 3.4 v2 1/2] ipv4: move route garbage collector
 to work queue
Date: Tue, 19 Aug 2014 17:31:50 -0300
Message-ID: <53F3B436.8050407@redhat.com>
References: <547688b69ee9a258cc04e4dad17a90ca6ab182d0.1408045325.git.mleitner@redhat.com>
Reply-To: mleitner@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hannes@redhat.com, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23839 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750808AbaHSUb5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Aug 2014 16:31:57 -0400
In-Reply-To: <547688b69ee9a258cc04e4dad17a90ca6ab182d0.1408045325.git.mleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 14-08-2014 16:44, Marcelo Ricardo Leitner escreveu:
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
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>
> Notes:
>      Hi,
>
>      This set is needed for stables <= 3.4, as the IPv4 route cache was
>      removed after that.
>
>      v1->v2: addressed indentation issue noticed by David Miller
>
>      Thanks!
>

Hi Dave,

Sorry to bother you but WDYT, is this patchset more appropriate?

Thanks,
Marcelo
