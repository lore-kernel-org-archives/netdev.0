From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6 12/12] net/mlx4_en: add prefetch in xdp rx path
Date: Fri, 08 Jul 2016 05:56:31 +0200
Message-ID: <1467950191.17638.3.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1467944124-14891-1-git-send-email-bblanco@plumgrid.com>
	 <1467944124-14891-13-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36279 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753628AbcGHD4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 23:56:40 -0400
Received: by mail-wm0-f66.google.com with SMTP id x83so126435wma.3
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2016 20:56:40 -0700 (PDT)
In-Reply-To: <1467944124-14891-13-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-07-07 at 19:15 -0700, Brenden Blanco wrote:
> XDP programs read and/or write packet data very early, and cache miss is
> seen to be a bottleneck.
> 
> Add prefetch logic in the xdp case 3 packets in the future. Throughput
> improved from 10Mpps to 12.5Mpps.  LLC misses as reported by perf stat
> reduced from ~14% to ~7%.  Prefetch values of 0 through 5 were compared
> with >3 showing dimishing returns.

This is what I feared with XDP.

Instead of making generic changes in the driver(s), we now have 'patches
that improve XDP numbers'

Careful prefetches make sense in NIC drivers, regardless of XDP being
used or not.

On mlx4, prefetching next cqe could probably help as well.
