From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: fix htab map destruction when extra reserve
 is in use
Date: Mon, 07 Nov 2016 13:21:38 -0500 (EST)
Message-ID: <20161107.132138.2135085089697860098.davem@davemloft.net>
References: <e8a8cc8011d16169eaf604b78583836ab2246f0e.1478213579.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org, dvyukov@google.com
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39240 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932794AbcKGSVk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 13:21:40 -0500
In-Reply-To: <e8a8cc8011d16169eaf604b78583836ab2246f0e.1478213579.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri,  4 Nov 2016 00:01:19 +0100

> Commit a6ed3ea65d98 ("bpf: restore behavior of bpf_map_update_elem")
> added an extra per-cpu reserve to the hash table map to restore old
> behaviour from pre prealloc times. When non-prealloc is in use for a
> map, then problem is that once a hash table extra element has been
> linked into the hash-table, and the hash table is destroyed due to
> refcount dropping to zero, then htab_map_free() -> delete_all_elements()
> will walk the whole hash table and drop all elements via htab_elem_free().
> The problem is that the element from the extra reserve is first fed
> to the wrong backend allocator and eventually freed twice.
> 
> Fixes: a6ed3ea65d98 ("bpf: restore behavior of bpf_map_update_elem")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied and queued up for -stable, thanks!
