From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Netperf UDP issue with connected sockets
Date: Wed, 16 Nov 2016 16:34:09 -0800
Message-ID: <1479342849.8455.233.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20140903165943.372b897b@redhat.com>
         <1409757426.26422.41.camel@edumazet-glaptop2.roam.corp.google.com>
         <20161116131609.4e5726b4@redhat.com>
         <7c4b43a4-74bf-1ee2-6f0d-17783b5d8fcb@hpe.com>
         <20161116234022.2bad179b@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hpe.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35239 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752906AbcKQAeL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 19:34:11 -0500
Received: by mail-pf0-f195.google.com with SMTP id i88so10581437pfk.2
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 16:34:10 -0800 (PST)
In-Reply-To: <20161116234022.2bad179b@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-11-16 at 23:40 +0100, Jesper Dangaard Brouer wrote:

> Using -R 1 does not seem to help remove __ip_select_ident()
> 
> Samples: 56K of event 'cycles', Event count (approx.): 78628132661
>   Overhead  Command        Shared Object        Symbol
> +    9.11%  netperf        [kernel.vmlinux]     [k] __ip_select_ident
> +    6.98%  netperf        [kernel.vmlinux]     [k] _raw_spin_lock
> +    6.21%  swapper        [mlx5_core]          [k] mlx5e_poll_tx_cq
> +    5.03%  netperf        [kernel.vmlinux]     [k] copy_user_enhanced_fast_string
> +    4.69%  netperf        [kernel.vmlinux]     [k] __ip_make_skb
> +    4.63%  netperf        [kernel.vmlinux]     [k] skb_set_owner_w
> +    4.15%  swapper        [kernel.vmlinux]     [k] __slab_free
> +    3.80%  netperf        [mlx5_core]          [k] mlx5e_sq_xmit
> +    2.00%  swapper        [kernel.vmlinux]     [k] sock_wfree
> +    1.94%  netperf        netperf              [.] send_data
> +    1.92%  netperf        netperf              [.] send_omni_inner

Check "ss -nu"  ?

You will see if sockets are connected (present in ss output or not)

UDP being connected does not prevent __ip_select_ident() being used.

    if ((iph->frag_off & htons(IP_DF)) && !skb->ignore_df) {

So you need IP_DF being set, and skb->ignore_df being 0

-> time to try IP_MTU_DISCOVER ;)
