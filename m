From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net V1 2/2] net/mlx4_en: Fix pages never dma unmapped on
 rx
Date: Mon, 07 Oct 2013 06:47:09 -0700
Message-ID: <1381153629.12191.4.camel@edumazet-glaptop.roam.corp.google.com>
References: <1381145893-20930-1-git-send-email-amirv@mellanox.com>
	 <1381145893-20930-3-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Eric Dumazet <edumazet@google.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:62134 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753856Ab3JGNrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 09:47:11 -0400
Received: by mail-pb0-f47.google.com with SMTP id rr4so7094208pbb.6
        for <netdev@vger.kernel.org>; Mon, 07 Oct 2013 06:47:10 -0700 (PDT)
In-Reply-To: <1381145893-20930-3-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-10-07 at 13:38 +0200, Amir Vadai wrote:
> This patch fixes a bug introduced by commit 51151a16 (mlx4: allow
> order-0 memory allocations in RX path).
> 
> dma_unmap_page never reached because condition to detect last fragment
> in page is wrong. offset+frag_stride can't be greater than size, need to
> make sure no additional frag will fit in page => compare offset +
> frag_stride + next_frag_size instead.
> next_frag_size is the same as the current one, since page is shared only
> with frags of the same size.
> 
> CC: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
> After looking at the code again, need to use 2*frag_stride and not to look at
> size of next frag in skb. Changed it accordingly

Yes indeed this looks much better, thanks !

Acked-by: Eric Dumazet <edumazet@google.com>
