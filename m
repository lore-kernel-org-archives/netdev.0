From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/mlx4_en: protect ring->xdp_prog with
 rcu_read_lock
Date: Tue, 06 Sep 2016 13:42:02 -0700 (PDT)
Message-ID: <20160906.134202.1118614463249936981.davem@davemloft.net>
References: <20160904042958.8594-1-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        alexei.starovoitov@gmail.com, ttoukan.linux@gmail.com,
        gerlitz.or@gmail.com, tom@herbertland.com,
        saeedm@dev.mellanox.co.il
To: bblanco@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53660 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934248AbcIFUmD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 16:42:03 -0400
In-Reply-To: <20160904042958.8594-1-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brenden Blanco <bblanco@plumgrid.com>
Date: Sat,  3 Sep 2016 21:29:58 -0700

> Depending on the preempt mode, the bpf_prog stored in xdp_prog may be
> freed despite the use of call_rcu inside bpf_prog_put. The situation is
> possible when running in PREEMPT_RCU=y mode, for instance, since the rcu
> callback for destroying the bpf prog can run even during the bh handling
> in the mlx4 rx path.
> 
> Several options were considered before this patch was settled on:
 ...
> v2:
> Remove extra rcu_read_lock in mlx4_en_process_rx_cq body
> Annotate xdp_prog with __rcu, and convert all usages to rcu_assign or
> rcu_dereference[_protected] as appropriate.
> Add explicit mutex lock around rcu_assign instead of xchg loop.
> 
> Fixes: d576acf0a22 ("net/mlx4_en: add page recycle to prepare rx ring for tx support")
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>

Applied.
