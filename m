From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next] mlx4: allow order-0 memory allocations in RX path
Date: Mon, 24 Jun 2013 17:09:21 +0300
Message-ID: <CAJZOPZ+zMjkrTBh76PdxDB-xsLjNFdiC6ZbEgTjeFF2fzpSyeQ@mail.gmail.com>
References: <1371757222-21412-1-git-send-email-amirv@mellanox.com>
	<1371757222-21412-2-git-send-email-amirv@mellanox.com>
	<1371763689.3252.419.camel@edumazet-glaptop>
	<51C6B602.20703@mellanox.com>
	<1372000676.3301.27.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:46190 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900Ab3FXOJW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 10:09:22 -0400
Received: by mail-qa0-f46.google.com with SMTP id ih17so2236134qab.19
        for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 07:09:21 -0700 (PDT)
In-Reply-To: <1372000676.3301.27.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 23, 2013 at 6:17 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Signed-off-by: Eric Dumazet <edumazet@google.com>
>
> mlx4 exclusively uses order-2 allocations in RX path, which are
> likely to fail under memory pressure.
>
> We therefore drop frames more than needed.
>
> This patch tries order-3, order-2, order-1 and finally order-0
> allocations to keep good performance, yet allow allocations if/when
> memory gets fragmented.
>
> By using larger pages, and avoiding unnecessary get_page()/put_page()
> on compound pages, this patch improves performance as well, lowering
> false sharing on struct page.
>
> Also use GFP_KERNEL allocations in initialization path, as allocating 12
> MB (390 order-3 pages) can easily fail with GFP_ATOMIC.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Amir Vadai <amirv@mellanox.com>

Eric, this looks brilliant, I am OOO today, so will give it a try on
my systems tomorrow and ack, thanks for the good work!

Or.
