From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] mlx4: optimize xmit path
Date: Sun, 28 Sep 2014 05:42:16 -0700
Message-ID: <1411908136.15768.72.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411692382-8898-1-git-send-email-ast@plumgrid.com>
	 <1411694414.16953.70.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411717322.16953.99.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411850590.15768.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJ3xEMhQCf7j48Yn5sjH6jaYYdLQUgOe2hk-OZhhdZ7taOyx+Q@mail.gmail.com>
	 <1411853441.15768.13.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411858593.15768.51.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <or.gerlitz@gmail.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:40071 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752880AbaI1MmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 08:42:18 -0400
Received: by mail-pa0-f45.google.com with SMTP id rd3so6341874pab.32
        for <netdev@vger.kernel.org>; Sun, 28 Sep 2014 05:42:17 -0700 (PDT)
In-Reply-To: <1411858593.15768.51.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-09-27 at 15:56 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>

>  
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---


>  
>  struct mlx4_en_tx_ring {
> +			/* cache line used and dirtied in tx completion
> +			 * (mlx4_en_free_tx_buf())
> +			 */
> +	u32			last_nr_txbb;
> +	u32			cons;
> +
> +			/* cache line used and dirtied in mlx4_en_xmit()
> +			 */
> +	u32			prod ____cacheline_aligned_in_smp;
> +	unsigned long		bytes;
> +	unsigned long		packets;
> +	unsigned long		tx_csum;
> +	struct mlx4_bf		bf;
> +	unsigned long		queue_stopped;
> +	unsigned long		wake_queue;
> +


Hmm, I forgot to move wake_queue in the first cache line.

I also forgot to include <linux/prefetch.h>

I'll send a v2.
