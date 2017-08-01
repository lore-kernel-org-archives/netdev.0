From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC net-next] net ipv6: convert fib6_table rwlock to a percpu
 lock
Date: Tue, 1 Aug 2017 07:45:28 -0700
Message-ID: <20170801074528.289fc520@xeon-e3>
References: <1a5ad2f0585aa66496b27e123d1c38b75552df4c.1501520674.git.shli@fb.com>
        <20170731161007.61c2d958@xeon-e3>
        <20170801025704.fuhxll23d3eenwrz@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, Kernel-team@fb.com,
        Shaohua Li <shli@fb.com>, Wei Wang <weiwan@google.com>
To: Shaohua Li <shli@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:35880 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751368AbdHAOpb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 10:45:31 -0400
Received: by mail-pg0-f48.google.com with SMTP id v77so3160181pgb.3
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 07:45:31 -0700 (PDT)
In-Reply-To: <20170801025704.fuhxll23d3eenwrz@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 31 Jul 2017 19:57:04 -0700
Shaohua Li <shli@kernel.org> wrote:

> On Mon, Jul 31, 2017 at 04:10:07PM -0700, Stephen Hemminger wrote:
> > On Mon, 31 Jul 2017 10:18:57 -0700
> > Shaohua Li <shli@kernel.org> wrote:
> >   
> > > From: Shaohua Li <shli@fb.com>
> > > 
> > > In a syn flooding test, the fib6_table rwlock is a significant
> > > bottleneck. While converting the rwlock to rcu sounds straighforward,
> > > but is very challenging if it's possible. A percpu spinlock is quite
> > > trival for this problem since updating the routing table is a rare
> > > event. In my test, the server receives around 1.5 Mpps in syn flooding
> > > test without the patch in a dual sockets and 56-CPU system. With the
> > > patch, the server receives around 3.8Mpps, and perf report doesn't show
> > > the locking issue.
> > > 
> > > Cc: Wei Wang <weiwan@google.com>  
> > 
> > You just reinvented brlock...

It was a long time ago (2.4) that brlock came in
 https://lwn.net/Articles/378781/

I removed it in 2.5.64 or so.
