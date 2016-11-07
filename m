From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: fix map not being uncharged during map
 creation failure
Date: Mon, 07 Nov 2016 13:23:55 -0500 (EST)
Message-ID: <20161107.132355.1099647347767603358.davem@davemloft.net>
References: <89c1a3a48ca9940a0fdc1298e11c03c4074a1c59.1478216947.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39272 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932691AbcKGSZ3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 13:25:29 -0500
In-Reply-To: <89c1a3a48ca9940a0fdc1298e11c03c4074a1c59.1478216947.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri,  4 Nov 2016 00:56:31 +0100

> In map_create(), we first find and create the map, then once that
> suceeded, we charge it to the user's RLIMIT_MEMLOCK, and then fetch
> a new anon fd through anon_inode_getfd(). The problem is, once the
> latter fails f.e. due to RLIMIT_NOFILE limit, then we only destruct
> the map via map->ops->map_free(), but without uncharging the previously
> locked memory first. That means that the user_struct allocation is
> leaked as well as the accounted RLIMIT_MEMLOCK memory not released.
> Make the label names in the fix consistent with bpf_prog_load().
> 
> Fixes: aaac3ba95e4c ("bpf: charge user for creation of BPF maps and programs")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied and queued up for -stable.
