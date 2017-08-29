From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 4/7] xdp: separate xdp_redirect tracepoint in
 error case
Date: Tue, 29 Aug 2017 10:02:51 -0700
Message-ID: <20170829170249.yqfq3cvvnnncszf3@ast-mbp>
References: <150401743083.16384.15778781741742858567.stgit@firesoul>
 <150401747611.16384.8021135230122395742.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, John Fastabend <john.fastabend@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35429 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751275AbdH2RC4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 13:02:56 -0400
Received: by mail-pg0-f68.google.com with SMTP id r133so3147352pgr.2
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 10:02:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <150401747611.16384.8021135230122395742.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 29, 2017 at 04:37:56PM +0200, Jesper Dangaard Brouer wrote:
> There is a need to separate the xdp_redirect tracepoint into two
> tracepoints, for separating the error case from the normal forward
> case.
> 
> Due to the extreme speeds XDP is operating at, loading a tracepoint
> have a measurable impact.  Single core XDP REDIRECT (ethtool tuned
> rx-usecs 25) can do 13.7 Mpps forwarding, but loading a simple
> bpf_prog at the tracepoint (with a return 0) reduce perf to 10.2 Mpps
> (CPU E5-1650 v4 @ 3.60GHz, driver: ixgbe)
> 
> The overhead of loading a bpf-based tracepoint can be calculated to
> cost 25 nanosec ((1/13782002-1/10267937)*10^9 = -24.83 ns).
> 
> Using perf record on the tracepoint event, with a non-matching --filter
> expression, the overhead is much larger. Performance drops to 8.3 Mpps,
> cost 48 nanosec ((1/13782002-1/8312497)*10^9 = -47.74))
> 
> Having a separate tracepoint for err cases, which should be less
> frequent, allow running a continuous monitor for errors while not
> affecting the redirect forward performance (this have also been
> verified by measurements).
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

thanks for detailed analysis of performance impact of the changes.
looks great to me.
Acked-by: Alexei Starovoitov <ast@kernel.org>
