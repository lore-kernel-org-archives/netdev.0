From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v10 07/12] net/mlx4_en: add page recycle to prepare rx
 ring for tx support
Date: Mon, 25 Jul 2016 09:35:20 +0200
Message-ID: <1469432120.8514.5.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
	 <1468955817-10604-8-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tariq Toukan <ttoukan.linux@gmail.com>
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33893 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752344AbcGYHfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 03:35:25 -0400
Received: by mail-wm0-f68.google.com with SMTP id q128so15461016wma.1
        for <netdev@vger.kernel.org>; Mon, 25 Jul 2016 00:35:24 -0700 (PDT)
In-Reply-To: <1468955817-10604-8-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-07-19 at 12:16 -0700, Brenden Blanco wrote:
> The mlx4 driver by default allocates order-3 pages for the ring to
> consume in multiple fragments. When the device has an xdp program, this
> behavior will prevent tx actions since the page must be re-mapped in
> TODEVICE mode, which cannot be done if the page is still shared.
> 
> Start by making the allocator configurable based on whether xdp is
> running, such that order-0 pages are always used and never shared.
> 
> Since this will stress the page allocator, add a simple page cache to
> each rx ring. Pages in the cache are left dma-mapped, and in drop-only
> stress tests the page allocator is eliminated from the perf report.
> 
> Note that setting an xdp program will now require the rings to be
> reconfigured.

Again, this has nothing to do with XDP ?

Please submit a separate patch, switching this driver to order-0
allocations.

I mentioned this order-3 vs order-0 issue earlier [1], and proposed to
send a generic patch, but had been traveling lately, and currently in
vacation.

order-3 pages are problematic when dealing with hostile traffic anyway,
so we should exclusively use order-0 pages, and page recycling like
Intel drivers.

http://lists.openwall.net/netdev/2016/04/11/88
