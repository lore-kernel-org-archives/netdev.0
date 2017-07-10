From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 10/12] xdp: Add batching support to redirect map
Date: Mon, 10 Jul 2017 19:53:55 +0200
Message-ID: <20170710195355.40fd9caa@redhat.com>
References: <20170707172115.9984.53461.stgit@john-Precision-Tower-5810>
        <20170707173759.9984.5709.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net,
        daniel@iogearbox.net, ast@fb.com, brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56526 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754658AbdGJRyD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Jul 2017 13:54:03 -0400
In-Reply-To: <20170707173759.9984.5709.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 07 Jul 2017 10:37:59 -0700
John Fastabend <john.fastabend@gmail.com> wrote:

> diff --git a/kernel/bpf/devmap.c b/kernel/bpf/devmap.c
> index 36dc13de..656e334 100644
> --- a/kernel/bpf/devmap.c
> +++ b/kernel/bpf/devmap.c
[...]
>  
> +void __dev_map_insert_ctx(struct bpf_map *map, u32 key)
> +{
> +	struct bpf_dtab *dtab = container_of(map, struct bpf_dtab, map);
> +	unsigned long *bitmap = this_cpu_ptr(dtab->flush_needed);
> +
> +	set_bit(key, bitmap);
> +}

I don't like that this adds an atomic op (set_bit) per packet on a fast-path.
It shows up on a perf top #6 with xdp_redirect_map.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
