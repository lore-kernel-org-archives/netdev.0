From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix refcnt leak with ebpf congestion control
Date: Fri, 25 Aug 2017 17:16:57 -0700 (PDT)
Message-ID: <20170825.171657.1442719401892146442.davem@davemloft.net>
References: <d69d1981d2c74805affc4ed6378447ea4cb06c67.1503659184.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brakmo@fb.com, daniel@iogearbox.net
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36974 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754033AbdHZAQ6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 20:16:58 -0400
In-Reply-To: <d69d1981d2c74805affc4ed6378447ea4cb06c67.1503659184.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Fri, 25 Aug 2017 13:10:12 +0200

> There are a few bugs around refcnt handling in the new BPF congestion
> control setsockopt:
> 
>  - The new ca is assigned to icsk->icsk_ca_ops even in the case where we
>    cannot get a reference on it. This would lead to a use after free,
>    since that ca is going away soon.
> 
>  - Changing the congestion control case doesn't release the refcnt on
>    the previous ca.
> 
>  - In the reinit case, we first leak a reference on the old ca, then we
>    call tcp_reinit_congestion_control on the ca that we have just
>    assigned, leading to deinitializing the wrong ca (->release of the
>    new ca on the old ca's data) and releasing the refcount on the ca
>    that we actually want to use.
> 
> This is visible by building (for example) BIC as a module and setting
> net.ipv4.tcp_congestion_control=bic, and using tcp_cong_kern.c from
> samples/bpf.
> 
> This patch fixes the refcount issues, and moves reinit back into tcp
> core to avoid passing a ca pointer back to BPF.
> 
> Fixes: 91b5b21c7c16 ("bpf: Add support for changing congestion control")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied, thank you.
