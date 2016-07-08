From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v6 12/12] net/mlx4_en: add prefetch in xdp rx path
Date: Fri, 8 Jul 2016 17:20:24 +0200
Message-ID: <20160708172024.4a849b7a@redhat.com>
References: <1467944124-14891-1-git-send-email-bblanco@plumgrid.com>
	<1467944124-14891-13-git-send-email-bblanco@plumgrid.com>
	<1467950191.17638.3.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Brenden Blanco <bblanco@plumgrid.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Martin KaFai Lau <kafai@fb.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>, brouer@redhat.com,
	Rana Shahout <rana.shahot@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44549 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755348AbcGHPUh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jul 2016 11:20:37 -0400
In-Reply-To: <1467950191.17638.3.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 08 Jul 2016 05:56:31 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Thu, 2016-07-07 at 19:15 -0700, Brenden Blanco wrote:
> > XDP programs read and/or write packet data very early, and cache miss is
> > seen to be a bottleneck.
> > 
> > Add prefetch logic in the xdp case 3 packets in the future. Throughput
> > improved from 10Mpps to 12.5Mpps.  LLC misses as reported by perf stat
> > reduced from ~14% to ~7%.  Prefetch values of 0 through 5 were compared
> > with >3 showing dimishing returns.  
> 
> This is what I feared with XDP.
> 
> Instead of making generic changes in the driver(s), we now have 'patches
> that improve XDP numbers'
> 
> Careful prefetches make sense in NIC drivers, regardless of XDP being
> used or not.

I feel the same way.  Our work on XDP should also benefit the normal
driver usage. Yes, I know that is much much harder to achieve, but it
will be worth it.


I've been playing with prefetch changes to mxl4 (and mlx5) what are generic. 
I'll post my patch as RFC.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
