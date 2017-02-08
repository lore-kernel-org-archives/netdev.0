From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf, lpm: fix overflows in trie_alloc checks
Date: Wed, 08 Feb 2017 14:40:38 -0500 (EST)
Message-ID: <20170208.144038.1724270145023687764.davem@davemloft.net>
References: <205e6ad77b5863daf0904e02f3cfc9a244e1ee47.1486513105.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, daniel@zonque.org, dh.herrmann@gmail.com,
        netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57396 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751075AbdBHTlY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 14:41:24 -0500
In-Reply-To: <205e6ad77b5863daf0904e02f3cfc9a244e1ee47.1486513105.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed,  8 Feb 2017 01:19:43 +0100

> Cap the maximum (total) value size and bail out if larger than KMALLOC_MAX_SIZE
> as otherwise it doesn't make any sense to proceed further, since we're
> guaranteed to fail to allocate elements anyway in lpm_trie_node_alloc();
> likleyhood of failure is still high for large values, though, similarly
> as with htab case in non-prealloc.
> 
> Next, make sure that cost vars are really u64 instead of size_t, so that we
> don't overflow on 32 bit and charge only tiny map.pages against memlock while
> allowing huge max_entries; cap also the max cost like we do with other map
> types.
> 
> Fixes: b95a5c4db09b ("bpf: add a longest prefix match trie map implementation")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied, thanks Daniel.
