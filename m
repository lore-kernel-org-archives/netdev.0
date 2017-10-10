From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/7] bpf: get rid of global verifier state
 and reuse instruction printer
Date: Tue, 10 Oct 2017 12:30:37 -0700 (PDT)
Message-ID: <20171010.123037.1660238025229239353.davem@davemloft.net>
References: <20171009173015.23520-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52494 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751168AbdJJTai (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 15:30:38 -0400
In-Reply-To: <20171009173015.23520-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Mon,  9 Oct 2017 10:30:08 -0700

> This set started off as simple extraction of eBPF verifier's instruction
> printer into a separate file but evolved into removal of global state.
> The purpose of moving instruction printing code is to be able to reuse it
> from the bpftool.
> 
> As far as the global verifier lock goes, this set removes the global
> variables relating to the log buffer, makes the one-time init done
> by bpf_get_skb_set_tunnel_proto() not depend on any external locking,
> and performs verifier log writeback as data is produced removing the need
> for allocating a potentially large temporary buffer.
> 
> The final step of actually removing the verifier lock is left to someone
> more competent and self-confident :)
> 
> Note that struct bpf_verifier_env is just 40B under two pages now,
> we should probably switch to vzalloc() when it's expanded again...
> 
> v2:
>  - add a selftest;
>  - use env buffer and flush on every print (Alexei);
>  - handle kernel log allocation failures (Daniel);
>  - put the env log members into a struct (Daniel).

Looks great, series applied, thanks Jakub.
