From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH RFC net] net/mlx5e: Add preemption enable/disable around
 TC statistics upcall
Date: Thu, 9 Feb 2017 17:34:41 -0800
Message-ID: <20170209173441.1f1eb96e@cakuba.netronome.com>
References: <1486654723-25777-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Amir Vadai <amir@vadai.me>, Ido Schimmel <idosch@mellanox.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Roi Dayan <roid@mellanox.com>, netdev@vger.kernel.org
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34289 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751448AbdBJBer (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 20:34:47 -0500
Received: by mail-pf0-f181.google.com with SMTP id e4so4821509pfg.1
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 17:34:45 -0800 (PST)
In-Reply-To: <1486654723-25777-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  9 Feb 2017 17:38:43 +0200, Or Gerlitz wrote:
> Running with CONFIG_PREEMPT set, I get a
> 
> BUG: using smp_processor_id() in preemptible [00000000] code: tc/3793
> 
> asserion from the TC action (mirred) stats_update callback, when the do
> 
> 	_bstats_cpu_update(this_cpu_ptr(a->cpu_bstats), bytes, packets)
> 
> As done by commit 66860be "nfp: bpf: allow offloaded filters to update stats",
> disabling/enabling preemption around the TC upcall solves that.
> 
> Fixes: aad7e08d39bd ('net/mlx5e: Hardware offloaded flower filter statistics support')
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---
> 
> I marked it as RFC, since I wasn't fully sure on the nature of the 
> problem, nor if this is the direction we should take to the fix.

I think it's the right fix, for net-next we could perhaps redo the
tcf_action_stats_update() helper so that it takes care of preemption and
the iteration so more people don't trip over this?
