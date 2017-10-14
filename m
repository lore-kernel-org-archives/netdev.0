From: David Miller <davem@davemloft.net>
Subject: Re: [net-next V7 PATCH 4/5] bpf: cpumap add tracepoints
Date: Sat, 14 Oct 2017 09:54:24 -0700 (PDT)
Message-ID: <20171014.095424.37500282847478638.davem@davemloft.net>
References: <150781116384.9409.2491501775270038284.stgit@firesoul>
        <150781122498.9409.14999232908601389565.stgit@firesoul>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jakub.kicinski@netronome.com,
        mst@redhat.com, pavel.odintsov@gmail.com, jasowang@redhat.com,
        mchan@broadcom.com, john.fastabend@gmail.com,
        peter.waskiewicz.jr@intel.com, ast@fiberby.dk,
        borkmann@iogearbox.net, alexei.starovoitov@gmail.com,
        andy@greyhouse.net
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33392 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751210AbdJNQy1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 12:54:27 -0400
In-Reply-To: <150781122498.9409.14999232908601389565.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Thu, 12 Oct 2017 14:27:05 +0200

> @@ -355,7 +360,10 @@ struct bpf_cpu_map_entry *__cpu_map_entry_alloc(u32 qsize, u32 cpu, int map_id)
>  	err = ptr_ring_init(rcpu->queue, qsize, gfp);
>  	if (err)
>  		goto free_queue;
> -	rcpu->qsize = qsize
> +
> +	rcpu->cpu    = cpu;
> +	rcpu->map_id = map_id;
> +	rcpu->qsize  = qsize;
>  
>  	/* Setup kthread */
>  	rcpu->kthread = kthread_create_on_node(cpu_map_kthread_run, rcpu, numa,

So this fixes a build failure (missing final semicolon) introduced by
an earlier patch in the series, please fix this up so that this series
is properly bisectable.
