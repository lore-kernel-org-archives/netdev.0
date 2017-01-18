From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: don't trigger OOM killer under pressure with
 map alloc
Date: Wed, 18 Jan 2017 17:13:54 -0500 (EST)
Message-ID: <20170118.171354.1392552826246839853.davem@davemloft.net>
References: <1f39f6b28b1ec25a88b90dd95aa4ea7820d0d53a.1484747846.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42444 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751235AbdARWU6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 17:20:58 -0500
In-Reply-To: <1f39f6b28b1ec25a88b90dd95aa4ea7820d0d53a.1484747846.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed, 18 Jan 2017 15:14:17 +0100

> This patch adds two helpers, bpf_map_area_alloc() and bpf_map_area_free(),
> that are to be used for map allocations. Using kmalloc() for very large
> allocations can cause excessive work within the page allocator, so i) fall
> back earlier to vmalloc() when the attempt is considered costly anyway,
> and even more importantly ii) don't trigger OOM killer with any of the
> allocators.
> 
> Since this is based on a user space request, for example, when creating
> maps with element pre-allocation, we really want such requests to fail
> instead of killing other user space processes.
> 
> Also, don't spam the kernel log with warnings should any of the allocations
> fail under pressure. Given that, we can make backend selection in
> bpf_map_area_alloc() generic, and convert all maps over to use this API
> for spots with potentially large allocation requests.
> 
> Note, replacing the one kmalloc_array() is fine as overflow checks happen
> earlier in htab_map_alloc(), since it must also protect the multiplication
> for vmalloc() should kmalloc_array() fail.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied, thanks.
