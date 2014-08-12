From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH stable 3.4 1/2] ipv4: move route garbage collector to
 work queue
Date: Tue, 12 Aug 2014 13:23:23 -0700
Message-ID: <1407875003.6804.0.camel@edumazet-glaptop2.roam.corp.google.com>
References: <fc0168a71c064457c18f2563371176380d0012c7.1407796232.git.mleitner@redhat.com>
	 <1407869404.27163.5.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Marcelo Ricardo Leitner <mleitner@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:53621 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753505AbaHLUXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 16:23:24 -0400
Received: by mail-pd0-f182.google.com with SMTP id fp1so13203948pdb.13
        for <netdev@vger.kernel.org>; Tue, 12 Aug 2014 13:23:24 -0700 (PDT)
In-Reply-To: <1407869404.27163.5.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-08-12 at 20:50 +0200, Hannes Frederic Sowa wrote:
> On Mo, 2014-08-11 at 19:41 -0300, Marcelo Ricardo Leitner wrote:
> > Currently the route garbage collector gets called by dst_alloc() if it
> > have more entries than the threshold. But it's an expensive call, that
> > don't really need to be done by then.
> > 
> > Another issue with current way is that it allows running the garbage
> > collector with the same start parameters on multiple CPUs at once, which
> > is not optimal. A system may even soft lockup if the cache is big enough
> > as the garbage collectors will be fighting over the hash lock entries.
> > 
> > This patch thus moves the garbage collector to run asynchronously on a
> > work queue, much similar to how rt_expire_check runs.
> > 
> > There is one condition left that allows multiple executions, which is
> > handled by the next patch.
> > 
> > Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
> > Cc: Hannes Frederic Sowa <hannes@redhat.com>
> 
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>


This does not look as stable material.

One can always disable route cache in 3.4 kernels
