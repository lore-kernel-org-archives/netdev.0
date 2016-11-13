From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf, mlx4: fix prog refcount in
 mlx4_en_try_alloc_resources error path
Date: Sat, 12 Nov 2016 23:34:09 -0500 (EST)
Message-ID: <20161112.233409.1021924000003441192.davem@davemloft.net>
References: <9d5b1ed1b70a8a4db545c308bcb5b28280564798.1478724690.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, bblanco@plumgrid.com,
        tariqt@mellanox.com, zhiyisun@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59936 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753498AbcKMEeL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 12 Nov 2016 23:34:11 -0500
In-Reply-To: <9d5b1ed1b70a8a4db545c308bcb5b28280564798.1478724690.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed,  9 Nov 2016 22:02:34 +0100

> Commit 67f8b1dcb9ee ("net/mlx4_en: Refactor the XDP forwarding rings
> scheme") added a bug in that the prog's reference count is not dropped
> in the error path when mlx4_en_try_alloc_resources() is failing from
> mlx4_xdp_set().
> 
> We previously took bpf_prog_add(prog, priv->rx_ring_num - 1), that we
> need to release again. Earlier in the call path, dev_change_xdp_fd()
> itself holds a reference to the prog as well (hence the '- 1' in the
> bpf_prog_add()), so a simple atomic_sub() is safe to use here. When
> an error is propagated, then bpf_prog_put() is called eventually from
> dev_change_xdp_fd()
> 
> Fixes: 67f8b1dcb9ee ("net/mlx4_en: Refactor the XDP forwarding rings scheme")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks Daniel.
