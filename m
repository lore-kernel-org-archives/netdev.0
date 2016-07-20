From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [PATCH v10 05/12] net/mlx4_en: add support for fast rx drop bpf
 program
Date: Wed, 20 Jul 2016 10:33:39 -0700
Message-ID: <20160720173338.GA16467@gmail.com>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
 <1468955817-10604-6-git-send-email-bblanco@plumgrid.com>
 <578F3F6D.5000903@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
	Tariq Toukan <ttoukan.linux@gmail.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34845 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753564AbcGTRdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 13:33:43 -0400
Received: by mail-pa0-f52.google.com with SMTP id iw10so20220361pac.2
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 10:33:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <578F3F6D.5000903@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 20, 2016 at 11:07:57AM +0200, Daniel Borkmann wrote:
> On 07/19/2016 09:16 PM, Brenden Blanco wrote:
[...]
> >+	if (ring->xdp_prog)
> >+		bpf_prog_put(ring->xdp_prog);
> 
> Would be good if you also make this a READ_ONCE() here. I believe this is the
> only other spot in your set that has this 'direct' access (besides xchg() and
> READ_ONCE() from mlx4_en_process_rx_cq()). It would be mostly for consistency
> and to indicate that there's a more complex synchronization behind it. I'm mostly
> worried that if it's not consistently used, people might copy this and not use
> the READ_ONCE() also in other spots where it matters, and thus add hard to find
> bugs.
I can do that. My thinking was just that this is the cleanup path so the
code would have been superfluous. I think there were a few nits so I'll
collect those and clean them up.
> 
[...]
