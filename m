From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net 1/4] net/mlx4_en: fix tx_dropped bug
Date: Wed, 25 May 2016 14:10:37 -0700
Message-ID: <20160525211035.GA64072@ast-mbp.thefacebook.com>
References: <1464195039-5098-1-git-send-email-edumazet@google.com>
 <1464195039-5098-2-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:34576 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738AbcEYVKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2016 17:10:42 -0400
Received: by mail-pa0-f67.google.com with SMTP id yl2so6404210pac.1
        for <netdev@vger.kernel.org>; Wed, 25 May 2016 14:10:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1464195039-5098-2-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 25, 2016 at 09:50:36AM -0700, Eric Dumazet wrote:
> 1) mlx4_en_xmit() can increment priv->stats.tx_dropped, but this variable
> is overwritten in mlx4_en_DUMP_ETH_STATS().
> 
> 2) This increment was not SMP safe, as a port might have many TX queues.
> 
> Add a per TX ring tx_dropped to fix these issues.
> 
> This is u32 as mlx4_en_DUMP_ETH_STATS() will add a 32bit field.
> 
> So lets avoid bugs with SNMP agents having to cope with partial
> overwraps. (One of these agents being bond_fold_stats())
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Willem de Bruijn <willemb@google.com>
> Cc: Eugenia Emantayev <eugenia@mellanox.com>

this problem was bugging me as well. thank you for fixing it.
Acked-by: Alexei Starovoitov <ast@kernel.org>
